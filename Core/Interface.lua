local _, JokUI = ...
local Interface = JokUI:RegisterModule("Interface")

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local features = {}

local font = STANDARD_TEXT_FONT

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------

local interface_defaults = {
    profile = {
    	UnitFrames = {
    		scale = 1.1,
    	},
    	BossFrame = {"TOPLEFT", nil, "TOPLEFT", 1250, -285},
    }
}

local interface_config = {
    title = {
        type = "description",
        name = "|cff64b4ffInterface",
        fontSize = "large",
        order = 0,
    },
    desc = {
        type = "description",
        name = "Various useful to customize interface.\n",
        fontSize = "medium",
        order = 1,
    },
    unitframes = {
        name = "Unit Frames",
        type = "group",
        inline = true,
        order = 2,
        args = {
            scale = {
                type = "range",
                isPercent = true,
                name = "Scale",
                desc = "",
                min = 0.5,
                max = 1.5,
                step = 0.05,
                order = 1,
                set = function(info,val) 
                    Interface.settings.UnitFrames.scale = val
                    PlayerFrame:SetScale(val)
					TargetFrame:SetScale(val)
					FocusFrame:SetScale(val)
                end,
                get = function(info) return Interface.settings.UnitFrames.scale end
            },	
        },
    },
}

function Interface:OnInitialize()
    self.db = JokUI.db:RegisterNamespace("Interface", interface_defaults)
    self.settings = self.db.profile
    JokUI.Config:Register("Interface", interface_config, 13)
end

function Interface:OnEnable()
	for name in pairs(features) do
		self:SyncFeature(name)
	end

	-- RAID FRAMES SIZE DEFAULT SLIDER
	local n,w,h="CompactUnitFrameProfilesGeneralOptionsFrame" h,w=
	_G[n.."HeightSlider"],
	_G[n.."WidthSlider"] 
	h:SetMinMaxValues(1,200) 
	w:SetMinMaxValues(1,200)

	self:UnitFrames()
	self:Chat()
	self:Minimap()
	self:Buffs()
	self:CastBars()
	self:ReAnchor()
	self:Mover()
	self:AutoQuest()
	self:BossFrame()
	self:Skin()
	self:RaidFrame()
end

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

function Interface:UnitFrames()
	-- SCALE
	PlayerFrame:SetScale(Interface.settings.UnitFrames.scale)
	TargetFrame:SetScale(Interface.settings.UnitFrames.scale)
	FocusFrame:SetScale(Interface.settings.UnitFrames.scale)

	TargetFrameTextureFramePVPIcon:SetAlpha(0)
	FocusFrameTextureFramePVPIcon:SetAlpha(0)

	--PET
	PetFrame:ClearAllPoints()
	PetFrame:SetScale(1.1)
	PetFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 80, -57)

	--HIDE COLORS BEHIND NAME
	hooksecurefunc("TargetFrame_CheckFaction", function(self)
	    self.nameBackground:SetVertexColor(0, 0, 0, 0.5);
	end)

	-- CLASS COLOR HP BAR
	local function colour(statusbar, unit)
		if self.isBossFrame then return end
        local _, class, c
        if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
            _, class = UnitClass(unit)
            c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
            statusbar:SetStatusBarColor(c.r, c.g, c.b)
        end
	end

	hooksecurefunc("UnitFrameHealthBar_Update", colour)
	hooksecurefunc("HealthBar_OnValueChanged", function(self)
	    colour(self, self.unit)
	end)

	-- HIT INDICATOR
	PlayerFrame:UnregisterEvent("UNIT_COMBAT")
	PetFrame:UnregisterEvent("UNIT_COMBAT")
end 

function Interface:Chat()

	CHAT_FRAME_FADE_TIME = 0.15
	CHAT_FRAME_FADE_OUT_TIME = 1
	CHAT_TAB_HIDE_DELAY = 0
	CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1
	CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0

	for i = 1, 7 do
		_G["ChatFrame" .. i]:SetFading(1)
	end

	ChatFrameMenuButton:HookScript("OnShow", ChatFrameMenuButton.Hide)
	ChatFrameMenuButton:Hide()

	-- Table to keep track of frames you already saw:
	local frames = {}

	-- Function to handle customzing a chat frame:
	local function ProcessFrame(frame)
		if frames[frame] then return end

		frame:SetClampRectInsets(0, 0, 0, 0)
		frame:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())
		frame:SetMinResize(250, 100)

		local name = frame:GetName()
		_G[name .. "ButtonFrame"]:Hide()
		_G[name .. "EditBoxLeft"]:Hide()
		_G[name .. "EditBoxMid"]:Hide()
		_G[name .. "EditBoxRight"]:Hide()

		local editbox = _G[name .. "EditBox"]
		editbox:ClearAllPoints()
		editbox:SetPoint("TOPLEFT", ChatFrame1, "BOTTOMLEFT", -7, 0)
		editbox:SetPoint("TOPRIGHT", ChatFrame1, "BOTTOMRIGHT", 10, 0)
		editbox:SetAltArrowKeyMode(false)

		local cf = _G[name]

		local tt = _G[name .. "ThumbTexture"]
		tt:Hide()
		tt.Show = function()
		end

		local sb = cf["ScrollBar"]
		sb:Show()
		sb.Show = function()
		end

		-- _G[name .. "EditBox"]:ClearAllPoints()
		-- _G[name .. "EditBox"]:SetPoint("TOPLEFT", UIParent, "CENTER", -100, -50)
		-- _G[name .. "EditBox"]:SetSize(250, 25)
		-- _G[name .. "EditBox"]:SetScale(1.1)
		-- _G[name.."EditBoxFocusLeft"]:SetTexture(nil)
		-- _G[name.."EditBoxFocusRight"]:SetTexture(nil)
		-- _G[name.."EditBoxFocusMid"]:SetTexture(nil)
		-- _G[name .. "EditBox"]:EnableMouse(false)


		cf:EnableMouse(1)
		ChatFrameChannelButton:EnableMouse(1)
		ChatFrameToggleVoiceDeafenButton:EnableMouse(1)
		ChatFrameToggleVoiceMuteButton:EnableMouse(1)
		ChatFrameChannelButton:SetAlpha(0)
		ChatFrameToggleVoiceDeafenButton:SetAlpha(0)
		ChatFrameToggleVoiceMuteButton:SetAlpha(0)

		cf:SetScript("OnEnter", function(self) 
			ChatFrameChannelButton:SetAlpha(0.8)	
			ChatFrameToggleVoiceDeafenButton:SetAlpha(0.8)
			ChatFrameToggleVoiceMuteButton:SetAlpha(0.8)
		end)
		cf:SetScript("OnLeave", function(self) 
			ChatFrameChannelButton:SetAlpha(0)	
			ChatFrameToggleVoiceDeafenButton:SetAlpha(0)
			ChatFrameToggleVoiceMuteButton:SetAlpha(0)
		end)

		ChatFrameChannelButton:SetScript("OnEnter", function(self) 
		ChatFrameChannelButton:SetAlpha(0.8)	
		ChatFrameToggleVoiceDeafenButton:SetAlpha(0.8)
		ChatFrameToggleVoiceMuteButton:SetAlpha(0.8)
		end)
		ChatFrameChannelButton:SetScript("OnLeave", function(self) 
		ChatFrameChannelButton:SetAlpha(0)	
		ChatFrameToggleVoiceDeafenButton:SetAlpha(0)
		ChatFrameToggleVoiceMuteButton:SetAlpha(0)
		end)
		ChatFrameToggleVoiceDeafenButton:SetScript("OnEnter", function(self) 
		ChatFrameChannelButton:SetAlpha(0.8)	
		ChatFrameToggleVoiceDeafenButton:SetAlpha(0.8)
		ChatFrameToggleVoiceMuteButton:SetAlpha(0.8)
		end)
		ChatFrameToggleVoiceDeafenButton:SetScript("OnLeave", function(self) 
		ChatFrameChannelButton:SetAlpha(0)	
		ChatFrameToggleVoiceDeafenButton:SetAlpha(0)
		ChatFrameToggleVoiceMuteButton:SetAlpha(0)
		end)
		ChatFrameToggleVoiceMuteButton:SetScript("OnEnter", function(self) 
		ChatFrameChannelButton:SetAlpha(0.8)	
		ChatFrameToggleVoiceDeafenButton:SetAlpha(0.8)
		ChatFrameToggleVoiceMuteButton:SetAlpha(0.8)
		end)
		ChatFrameToggleVoiceMuteButton:SetScript("OnLeave", function(self) 
		ChatFrameChannelButton:SetAlpha(0)	
		ChatFrameToggleVoiceDeafenButton:SetAlpha(0)
		ChatFrameToggleVoiceMuteButton:SetAlpha(0)
		end)

		frames[frame] = true
	end

	-- Loop Through Chat Windows
	for i = 1, NUM_CHAT_WINDOWS do
	    ProcessFrame(_G["ChatFrame" .. i])
		local chatWindowName = _G["ChatFrame"..i]:GetName();
		local name, size, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);

		-- Change Chat Tabs
		local chatTab = _G[chatWindowName.."Tab"];

		--Hide Tab Backgrounds
		_G[chatWindowName.."TabLeft"]:SetTexture( nil );
		_G[chatWindowName.."TabMiddle"]:SetTexture( nil );
		_G[chatWindowName.."TabRight"]:SetTexture( nil );
		_G[chatWindowName.."TabSelectedLeft"]:SetTexture(nil)
		_G[chatWindowName.."TabSelectedMiddle"]:SetTexture(nil)
		_G[chatWindowName.."TabSelectedRight"]:SetTexture(nil)

		_G[chatWindowName .. "RightTexture"]:SetTexture(nil)
		_G[chatWindowName .. "TopTexture"]:SetTexture(nil)
		_G[chatWindowName .. "BottomTexture"]:SetTexture(nil)
		_G[chatWindowName .. "LeftTexture"]:SetTexture(nil)
		_G[chatWindowName .. "Background"]:Hide()

		_G[chatWindowName.."ButtonFrameBackground"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameLeftTexture"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameRightTexture"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameTopTexture"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameTopRightTexture"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameTopLeftTexture"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameBottomTexture"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameBottomRightTexture"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameBottomLeftTexture"]:SetTexture( nil );
		chatTab:SetAlpha( 1.0 );
	end

	local faneifyTab = function(frame, sel)
		local i = frame:GetID()

		if (not frame.Fane) then
			frame.leftTexture:Hide()
			frame.middleTexture:Hide()
			frame.rightTexture:Hide()

			frame.leftSelectedTexture:Hide()
			frame.middleSelectedTexture:Hide()
			frame.rightSelectedTexture:Hide()

			frame.leftSelectedTexture.Show = frame.leftSelectedTexture.Hide
			frame.middleSelectedTexture.Show = frame.middleSelectedTexture.Hide
			frame.rightSelectedTexture.Show = frame.rightSelectedTexture.Hide

			frame.Fane = true
		end
	end

	hooksecurefunc("FCFTab_UpdateColors", faneifyTab)
	for i = 1, 7 do
		faneifyTab(_G["ChatFrame" .. i .. "Tab"])
	end

	-- Set up a dirty hook to catch temporary windows and customize them when they are created:
	local old_OpenTemporaryWindow = FCF_OpenTemporaryWindow
	FCF_OpenTemporaryWindow = function(...)
		local frame = old_OpenTemporaryWindow(...)
		ProcessFrame(frame)
		return frame
	end

	----------------------------------------------------------------------
	-- Unclamp chat frame
	----------------------------------------------------------------------

	-- Process normal and existing chat frames on startup
	for i = 1, 50 do
		if _G["ChatFrame" .. i] then 
			_G["ChatFrame" .. i]:SetClampRectInsets(0, 0, 0, 0);
		end
	end

	-- Set local channel colors
	for i = 1, 18 do
		if _G["ChatConfigChatSettingsLeftCheckBox" .. i .. "Check"] then
			ToggleChatColorNamesByClassGroup(true, _G["ChatConfigChatSettingsLeftCheckBox" .. i .. "Check"]:GetParent().type)
		end
	end

	-- Set global channel colors
	for i = 1, 50 do
		ToggleChatColorNamesByClassGroup(true, "CHANNEL" .. i)
	end

	-- URL CLICK
	function formatURL(url)
	    url = "|cff".."149bfd".."|Hurl:"..url.."|h["..url.."]|h|r ";
	    return url;
	end

	-- derived from EasyUrl by jklaroe
	function makeClickable(self, event, msg, ...)
	    if string.find(msg, "(%a+)://(%S+)%s?") then
	        return false, string.gsub(msg, "(%a+)://(%S+)%s?", formatURL("%1://%2")), ...
	    end

	    if string.find(msg, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?") then
	        return false, string.gsub(msg, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", formatURL("www.%1.%2")), ...
	    end

	    if string.find(msg, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?") then
	        return false, string.gsub(msg, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", formatURL("%1@%2%3%4")), ...
	    end

	    if string.find(msg, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?):(%d%d?%d?%d?%d?)%s?") then
	        return false, string.gsub(msg, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?):(%d%d?%d?%d?%d?)%s?", formatURL("%1.%2.%3.%4:%5")), ...
	    end

	    if string.find(msg, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?") then
	        return false, string.gsub(msg, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?", formatURL("%1.%2.%3.%4")), ...
	    end
	end

	StaticPopupDialogs["CLICK_LINK_CLICKURL"] = {
	    text = "Copy/Paste the link into your browser",
	    button1 = "Close",
	    OnAccept = function()
	    end,
	    timeout = 0,
	    whileDead = true,
	    hideOnEscape = true,
	    preferredIndex = 3, 
	    OnShow = function (self, data)
	    self.editBox:SetText(data.url)
	    self.editBox:HighlightText()
	    end,
	    hasEditBox = true
	}

	local SetItemRef_orig = SetItemRef;
	function ClickURL_SetItemRef(link, text, button)
	    if (string.sub(link, 1, 3) == "url") then
	        local url = string.sub(link, 5);
	        local d = {}
	        d.url = url
	        StaticPopup_Show("CLICK_LINK_CLICKURL", "", "", d)
	    else
	        SetItemRef_orig(link, text, button);
	    end
	end
	SetItemRef = ClickURL_SetItemRef;

	ChatFrame_AddMessageEventFilter("CHAT_MSG_COMMUNITIES_CHANNEL", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN", makeClickable)
end

function Interface:CastBars()
	local max = math.max
	local format = string.format

	if not InCombatLockdown() then

		-- Channels Ticks

		local sparkfactory = {
			__index = function(t,k)
				local spark = CastingBarFrame:CreateTexture(nil, 'OVERLAY')
				t[k] = spark
				spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
				spark:SetVertexColor(1, 1, 1, 1)
				spark:SetBlendMode('ADD')
				spark:SetWidth(20)
				spark:SetHeight(CastingBarFrame:GetHeight()*2.2)
				return spark
			end
		}
		local barticks = setmetatable({}, sparkfactory)

		local function setBarTicks(ticknum, duration, ticks)
			if( ticknum and ticknum > 0) then
				local width = CastingBarFrame:GetWidth()
				for k = 1, ticknum do
					local t = barticks[k]
					t:ClearAllPoints()
					local x = ticks[k] / duration
					t:SetPoint("CENTER", CastingBarFrame, "RIGHT", -width * x, 0 )
					t:Show()
				end
				barticks[1]:Hide()
				for k = ticknum+1, #barticks do
					barticks[k]:Hide()
				end
			else
				barticks[1].Hide = nil
				for i=1,#barticks do
					barticks[i]:Hide()
				end
			end
		end

		-- TODO: this will need updates for Cataclysm
		local channelingTicks = {
			-- warlock
			[GetSpellInfo(234153)] = 6, -- drain life
			[GetSpellInfo(193440)] = 3, -- demonwrath
			[GetSpellInfo(198590)] = 6, -- drain soul
			-- druid
			[GetSpellInfo(740)] = 4, -- tranquility
			-- priest
			[GetSpellInfo(64843)] = 4, -- divine hymn
			[GetSpellInfo(15407)] = 4, -- mind flay
			[GetSpellInfo(48045)] = 4, -- mind sear
			[GetSpellInfo(47540)] = 2, -- penance
			[GetSpellInfo(205065)] = 5, -- void torrent
			-- mage
			[GetSpellInfo(5143)] = 5, -- arcane missiles
			[GetSpellInfo(12051)] = 3, -- evocation
			[GetSpellInfo(205021)] = 10, -- ray of frost
			-- monk
			[GetSpellInfo(117952)] = 4, -- crackling jade lightning
			[GetSpellInfo(191837)] = 3, -- essence font
		}

		local function getChannelingTicks(spell)			
			return channelingTicks[spell] or 0
		end

		local frame = CreateFrame("Frame", "ChannelTicks", UIParent)

		frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
		frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		frame:RegisterEvent("UNIT_SPELLCAST_DELAYED")

		frame:SetScript("OnEvent", function(self, event, ...)
			if event == "UNIT_SPELLCAST_CHANNEL_START" then
				local unit = ...
				local bar = CastingBarFrame
				if bar.channeling and unit == "player" then
					local spell, _, _, startTime, endTime = UnitChannelInfo(unit)
					bar.channelingDuration = endTime - startTime
					bar.channelingEnd = endTime
					bar.channelingTicks = getChannelingTicks(spell)
					bar.channelingTickTime = bar.channelingTicks > 0 and (bar.channelingDuration / bar.channelingTicks) or 0
					bar.ticks = bar.ticks or {}
					for i = 1, bar.channelingTicks do
						bar.ticks[i] = bar.channelingDuration - (i - 1) * bar.channelingTickTime
					end
					setBarTicks(bar.channelingTicks, bar.channelingDuration, bar.ticks)
				end
			elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
				local unit = ...
				local bar = CastingBarFrame
				if unit == "player" then
					setBarTicks(0)
					bar.channelingDuration = nil
				end
			-- elseif event == "UNIT_SPELLCAST_DELAYED" then
			-- 	local unit = ...
			-- 	local bar = CastingBarFrame
			-- 	if bar.channeling and bar.endTime > bar.channelingEnd then
			-- 		local duration = bar.endTime - bar.startTime
			-- 		if bar.channelingDuration and duration > bar.channelingDuration and bar.channelingTicks > 0 then
			-- 			local extraTime = (duration - bar.channelingDuration)
			-- 			for i = 1, bar.channelingTicks do
			-- 				bar.ticks[i] = bar.ticks[i] + extraTime
			-- 			end
			-- 			while bar.ticks[bar.channelingTicks] > bar.channelingTickTime do
			-- 				bar.channelingTicks = bar.channelingTicks + 1
			-- 				bar.ticks[bar.channelingTicks] = bar.ticks[bar.channelingTicks-1] - bar.channelingTickTime
			-- 			end
			-- 			bar.channelingDuration = duration
			-- 			bar.channelingEnd = bar.endTime
			-- 			setBarTicks(bar.channelingTicks, bar.channelingDuration, bar.ticks)
			-- 		end
			-- 	end
			end
		end)

		-- Player Castbar
		CastingBarFrame:SetScale(1.1)

 		CastingBarFrame.Icon:Show()
		CastingBarFrame.Icon:ClearAllPoints()
		CastingBarFrame.Icon:SetSize(22, 22)
    	CastingBarFrame.Icon:SetPoint("RIGHT", CastingBarFrame, "LEFT", -7, 0)

  		CastingBarFrame.Text:ClearAllPoints()
  		CastingBarFrame.Text:SetPoint("CENTER", 0, 1)

  		CastingBarFrame.BorderShield:SetWidth(CastingBarFrame.BorderShield:GetWidth() + 4)
  		CastingBarFrame.BorderShield:SetPoint("TOP", 0, 26)
  		CastingBarFrame.Border:SetPoint("TOP", 0, 26)
 		CastingBarFrame.Flash:SetPoint("TOP", 0, 26)

 		-- Player Timer
		CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil)
		CastingBarFrame.timer:SetFont(STANDARD_TEXT_FONT, 14,'THINOUTLINE')
		CastingBarFrame.timer:SetPoint("LEFT", CastingBarFrame, "RIGHT", 7, 0)
		CastingBarFrame.update = 0.1

		-- Target Castbar
		TargetFrameSpellBar:SetScale(1.1)
  		TargetFrameSpellBar.Icon:SetPoint("RIGHT", TargetFrameSpellBar, "LEFT", -3, 0)

		-- Target Timer
		TargetFrameSpellBar.timer = TargetFrameSpellBar:CreateFontString(nil)
		TargetFrameSpellBar.timer:SetFont(STANDARD_TEXT_FONT, 11,'THINOUTLINE')
		TargetFrameSpellBar.timer:SetPoint("LEFT", TargetFrameSpellBar, "RIGHT", 4, 0)
		TargetFrameSpellBar.update = 0.1

		-- Focus Castbar
		FocusFrameSpellBar:SetScale(1.1)
  		FocusFrameSpellBar.Icon:SetPoint("RIGHT", FocusFrameSpellBar, "LEFT", -3, 0)

		-- Target Timer
		FocusFrameSpellBar.timer = FocusFrameSpellBar:CreateFontString(nil)
		FocusFrameSpellBar.timer:SetFont(STANDARD_TEXT_FONT, 11,'THINOUTLINE')
		FocusFrameSpellBar.timer:SetPoint("LEFT", FocusFrameSpellBar, "RIGHT", 4, 0)
		FocusFrameSpellBar.update = 0.1
	end

	-- CastBar timer function
	local function CastingBarFrame_OnUpdate_Hook(self, elapsed)
		if not self.timer then return end
		if self.update and self.update < elapsed then
			if self.casting then
				self.timer:SetText(format("%.1f", max(self.maxValue - self.value, 0)))
			elseif self.channeling then
				self.timer:SetText(format("%.1f", max(self.value, 0)))
			else
				self.timer:SetText("")
			end
			self.update = .1
		  else
			self.update = self.update - elapsed
		end
	end

	CastingBarFrame:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)
	TargetFrameSpellBar:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)
	FocusFrameSpellBar:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)
end

function Interface:Minimap()

	MinimapBorderTop:Hide()	
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	MiniMapWorldMapButton:Hide()
	MinimapZoneText:SetPoint("CENTER", Minimap, 0, 80)
	MinimapCluster:SetScale(1.2)
	GameTimeFrame:Hide()
	GameTimeFrame:UnregisterAllEvents()
	GameTimeFrame.Show = kill
	MiniMapTracking:Hide()
	MiniMapTracking.Show = kill
	MiniMapTracking:UnregisterAllEvents()
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(self, z)
		local c = Minimap:GetZoom()
		if(z > 0 and c < 5) then
			Minimap:SetZoom(c + 1)
		elseif(z < 0 and c > 0) then
			Minimap:SetZoom(c - 1)
		end
	end)
	Minimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" then
			_G.ToggleDropDownMenu(1, nil, _G.MiniMapTrackingDropDown, self)
		elseif btn == "MiddleButton" then
			_G.GameTimeFrame:Click()
		else
			_G.Minimap_OnClick(self)
		end
	end)
end

function Interface:Buffs()

	-- buff frame settings

	local buffFrame = {
	    pos                 = { a1 = "TOPRIGHT", af = "MinimapCluster", a2 = "TOPLEFT", x = 0, y = -20 },
	    gap                 = 30, --gap between buff and debuff rows
	    userplaced          = true, --want to place the bar somewhere else?
	    rowSpacing          = 12,
	    colSpacing          = 7,
	    buttonsPerRow       = 10,
	    button = {
	      size              = 45,
	    },

	    icon = {
	      padding           = -2,
	    },

	    border = {
	      texture           = "Interface\\AddOns\\JokUI\\media\\textures\\gloss",
	      color             = { r = 0.4, g = 0.35, b = 0.35, },
	      classcolored      = false,
	    },

	    background = {
	      show              = false,   --show backdrop
	      edgeFile          = "Interface\\AddOns\\JokUI\\media\\textures\\outer_shadow",
	      color             = { r = 0, g = 0, b = 0, a = 0.9},
	      classcolored      = false,
	      inset             = 6,
	      padding           = 2,
	    },

	    duration = {
	      font              = STANDARD_TEXT_FONT,
	      size              = 13,
	      pos               = { a1 = "BOTTOM", x = 0, y = -13 },
	    },

	    count = {
	      font              = STANDARD_TEXT_FONT,
	      size              = 11,
	      pos               = { a1 = "TOPRIGHT", x = 0, y = 0 },
	    },
	}
	  
	-- debuff frame settings

	local debuffFrame = {    
		pos             = { a1 = "TOPRIGHT", af = "MinimapCluster", a2 = "TOPLEFT", x = 0, y = -105 },
	    gap                 = 10, --gap between buff and debuff rows
	    userplaced          = true, --want to place the bar somewhere else?
	    rowSpacing          = 10,
	    colSpacing          = 7,
	    buttonsPerRow       = 10,

	    button = {
	      size              = 50,
	    },

	    icon = {
	      padding           = -2,
	    },

	    border = {
	      texture           = "Interface\\AddOns\\JokUI\\media\\textures\\gloss",
	      color             = { r = 0.4, g = 0.35, b = 0.35, },
	      classcolored      = false,
	    },

	    background = {
	      show              = true,   --show backdrop
	      edgeFile          = "Interface\\AddOns\\JokUI\\media\\textures\\outer_shadow",
	      color             = { r = 0, g = 0, b = 0, a = 0.9},
	      classcolored      = false,
	      inset             = 6,
	      padding           = 4,
	    },

	    duration = {
	      font              = STANDARD_TEXT_FONT,
	      size              = 13,
	      pos               = { a1 = "BOTTOM", x = 0, y = -13 },
	    },

	    count = {
	      font              = STANDARD_TEXT_FONT,
	      size              = 11,
	      pos               = { a1 = "TOPRIGHT", x = 0, y = 0 },
	    },
	}

	--rewrite the oneletter shortcuts

	HOUR_ONELETTER_ABBR = "%dh"
	DAY_ONELETTER_ABBR = "%dd"
	MINUTE_ONELETTER_ABBR = "%dm"
	--SECOND_ONELETTER_ABBR = "%ds"

	--backdrop debuff

	local backdropDebuff = {
	    bgFile = nil,
	    edgeFile = debuffFrame.background.edgeFile,
	    tile = false,
	    tileSize = 32,
	    edgeSize = debuffFrame.background.inset,
	    insets = {
	      left = debuffFrame.background.inset,
	      right = debuffFrame.background.inset,
	      top = debuffFrame.background.inset,
	      bottom = debuffFrame.background.inset,
	    },
	}

	--backdrop buff

	local backdropBuff = {
	    bgFile = nil,
	    edgeFile = buffFrame.background.edgeFile,
	    tile = false,
	    tileSize = 32,
	    edgeSize = buffFrame.background.inset,
	    insets = {
	      left = buffFrame.background.inset,
	      right = buffFrame.background.inset,
	      top = buffFrame.background.inset,
	      bottom = buffFrame.background.inset,
	    },
	}

	local ceil, min, max = ceil, min, max
	local buffFrameHeight = 0

	--apply aura frame texture func

	local function applySkin(b)
	    if not b or (b and b.styled) then return end

	    local name = b:GetName()

	    local tempenchant, consolidated, debuff, buff = false, false, false, false
	    if (name:match("TempEnchant")) then
	      tempenchant = true
	    elseif (name:match("Consolidated")) then
	      consolidated = true
	    elseif (name:match("Debuff")) then
	      debuff = true
	    else
	      buff = true
	    end

	    local cfg, backdrop
	    if debuff then
	      cfg = debuffFrame
	      backdrop = backdropDebuff
	    else
	      cfg = buffFrame
	      backdrop = backdropBuff
	    end

		--check class coloring options

	    --button
	    b:SetSize(buffFrame.button.size, buffFrame.button.size)

	    --icon
	    local icon = _G[name.."Icon"]
	    if consolidated then
		    if select(1,UnitFactionGroup("player")) == "Alliance" then  
		        icon:SetTexture(select(3,GetSpellInfo(61573)))
		    elseif select(1,UnitFactionGroup("player")) == "Horde" then
		    	icon:SetTexture(select(3,GetSpellInfo(61574)))
		    end
	    end
	    icon:SetTexCoord(0.1,0.9,0.1,0.9)
	    icon:ClearAllPoints()
	    icon:SetPoint("TOPLEFT", b, "TOPLEFT", -buffFrame.icon.padding, buffFrame.icon.padding)
	    icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", buffFrame.icon.padding, -buffFrame.icon.padding)
	    icon:SetDrawLayer("BACKGROUND",-8)
	    b.icon = icon

	    --border
	    local border = _G[name.."Border"] or b:CreateTexture(name.."Border", "BACKGROUND", nil, -7)
	    -- border:SetTexture(border.texture)
	    -- border:SetTexCoord(0,1,0,1)
	    -- border:SetDrawLayer("BACKGROUND",-7)
	    -- if tempenchant then
	    --   border:SetVertexColor(0.7,0,1)
	    -- elseif not debuff then
	    --   border:SetVertexColor(buffFrame.border.color.r,buffFrame.border.color.g,buffFrame.border.color.b)
	    -- end
	    -- border:ClearAllPoints()
	    border:SetAllPoints(b)
	    border:SetSize(buffFrame.button.size+4, buffFrame.button.size+4)
	    b.border = border

	    --duration
	    b.duration:SetFont(buffFrame.duration.font, buffFrame.duration.size, "THINOUTLINE")
	    b.duration:ClearAllPoints()
	    b.duration:SetPoint(buffFrame.duration.pos.a1,buffFrame.duration.pos.x,buffFrame.duration.pos.y)

	    --count
	    --b.count:SetFont(buffFrame.count.font, buffFrame.count.size, "THINOUTLINE")
	    -- b.count:ClearAllPoints()
	    -- b.count:SetPoint(buffFrame.count.pos.a1,buffFrame.count.pos.x,buffFrame.count.pos.y)

	    --shadow
	    if not buffFrame.background.show then
	      local back = CreateFrame("Frame", nil, b)
	      back:SetPoint("TOPLEFT", b, "TOPLEFT", -buffFrame.background.padding, buffFrame.background.padding)
	      back:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", buffFrame.background.padding, -buffFrame.background.padding)
	      back:SetFrameLevel(b:GetFrameLevel() - 1)
	      back:SetBackdrop(backdrop)
	      back:SetBackdropBorderColor(buffFrame.background.color.r,buffFrame.background.color.g,buffFrame.background.color.b,buffFrame.background.color.a)
	      b.bg = back
	    end

	    --set button styled variable
	    b.styled = true
	end

	--update debuff anchors

	local function updateDebuffAnchors(buttonName,index)
	    local button = _G[buttonName..index]
	    if not button then return end
	    --apply skin
	    if not button.styled then applySkin(button) end
	    --position button
	    button:ClearAllPoints()
	    if index == 1 then
	        --debuffs and buffs are not combined anchor the debuffs to its own frame
	        button:SetPoint("TOPRIGHT", rBFS_DebuffDragFrame, "TOPRIGHT", 0, -60)      
	    elseif index > 1 and mod(index, debuffFrame.buttonsPerRow) == 1 then
	      button:SetPoint("TOPRIGHT", _G[buttonName..(index-debuffFrame.buttonsPerRow)], "BOTTOMRIGHT", 0, -debuffFrame.rowSpacing)
	    else
	      button:SetPoint("TOPRIGHT", _G[buttonName..(index-1)], "TOPLEFT", -debuffFrame.colSpacing, 0)
	    end
	end

	--update buff anchors

	local function updateAllBuffAnchors()
	    --variables
	    local buttonName  = "BuffButton"
	    local numEnchants = BuffFrame.numEnchants
	    local numBuffs    = BUFF_ACTUAL_DISPLAY
	    local offset      = numEnchants
	    local realIndex, previousButton, aboveButton

	      TempEnchant1:ClearAllPoints()
	      TempEnchant1:SetPoint("TOPRIGHT", rBFS_BuffDragFrame, "TOPRIGHT", 0, 0)
	    
	    --calculate the previous button in case tempenchant or consolidated buff are loaded
	    if BuffFrame.numEnchants > 0 then
	      previousButton = _G["TempEnchant"..numEnchants]
	    end

	    if numEnchants > 0 then
	      aboveButton = TempEnchant1
	    end

	    --loop on all active buff buttons
	    local buffCounter = 0
	    for index = 1, numBuffs do
	      local button = _G[buttonName..index]
	      if not button then return end
	      if not button.consolidated then
	        buffCounter = buffCounter + 1
	        --apply skin
	        if not button.styled then applySkin(button) end
	        --position button
	        button:ClearAllPoints()
	        realIndex = buffCounter+offset
	        if realIndex == 1 then
	          button:SetPoint("TOPRIGHT", rBFS_BuffDragFrame, "TOPRIGHT", 0, 0)
	          aboveButton = button
	        elseif realIndex > 1 and mod(realIndex, buffFrame.buttonsPerRow) == 1 then
	          button:SetPoint("TOPRIGHT", aboveButton, "BOTTOMRIGHT", 0, -buffFrame.rowSpacing)
	          aboveButton = button
	        else
	          button:SetPoint("TOPRIGHT", previousButton, "TOPLEFT", -buffFrame.colSpacing, 0)
	        end
	        previousButton = button
	        
	      end
	    end
	    --calculate the height of the buff rows for the debuff frame calculation later
	    local rows = ceil((buffCounter+offset)/buffFrame.buttonsPerRow)
	    local height = buffFrame.button.size*rows + buffFrame.rowSpacing*rows + buffFrame.gap*min(1,rows)
	    buffFrameHeight = height
	end

	--buff drag frame

	local bf = CreateFrame("Frame", "rBFS_BuffDragFrame", UIParent)
	bf:SetSize(buffFrame.button.size,buffFrame.button.size)
	bf:SetPoint(buffFrame.pos.a1,buffFrame.pos.af,buffFrame.pos.a2,buffFrame.pos.x,buffFrame.pos.y)

	--debuff drag frame

	local df = CreateFrame("Frame", "rBFS_DebuffDragFrame", UIParent)
	df:SetSize(debuffFrame.button.size,debuffFrame.button.size)
	df:SetPoint(debuffFrame.pos.a1,debuffFrame.pos.af,debuffFrame.pos.a2,debuffFrame.pos.x,debuffFrame.pos.y)

	 --temp enchant stuff
	applySkin(TempEnchant1)
	applySkin(TempEnchant2)
	applySkin(TempEnchant3)

	  --position the temp enchant buttons
	TempEnchant1:ClearAllPoints()
	TempEnchant1:SetPoint("TOPRIGHT", rBFS_BuffDragFrame, "TOPRIGHT", 0, 0) --button will be repositioned later in case temp enchant and consolidated buffs are both available
	TempEnchant2:ClearAllPoints()
	TempEnchant2:SetPoint("TOPRIGHT", TempEnchant1, "TOPLEFT", -buffFrame.colSpacing, 0)
	TempEnchant3:ClearAllPoints()
	TempEnchant3:SetPoint("TOPRIGHT", TempEnchant2, "TOPLEFT", -buffFrame.colSpacing, 0)
	  
	--hook Blizzard functions
	hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", updateAllBuffAnchors)
	hooksecurefunc("DebuffButton_UpdateAnchors", updateDebuffAnchors)
end

function Interface:ReAnchor()

  	-- ETC
  	VerticalMultiBarsContainer:SetPoint("TOP", MinimapCluster, "BOTTOM", -2, 0)
  	MicroButtonAndBagsBar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 5, -4)

  	for i,v in pairs({
		MainMenuBarBackpackButton,
  		CharacterBag0Slot,
  		CharacterBag1Slot,
  		CharacterBag2Slot,
  		CharacterBag3Slot,
  		MicroButtonAndBagsBar.MicroBagBar,
	}) do
        v:Hide()
	end	

	if InCombatLockdown() then return end

	C_Timer.After(0.3, function()
		LoadAddOn("Blizzard_OrderHallUI")
		local b = OrderHallCommandBar
		b:UnregisterAllEvents()
		b:HookScript("OnShow", b.Hide)
		b:Hide()
	end)
end

function Interface:AutoQuest()

	----------------------------------------------------------------------
	--	Automate quests
	----------------------------------------------------------------------

	-- Function to show quest dialog for popup quests in the objective tracker
	local function PopupQuestComplete()
		if GetNumAutoQuestPopUps() > 0 then
			local questId, questType = GetAutoQuestPopUp(1)
			if questType == "COMPLETE" then
				local index = GetQuestLogIndexByID(questId)
				ShowQuestComplete(index)
			end
		end
	end

	-- Funcion to ignore specific NPCs
	local function isNpcBlocked(actionType)
		local npcGuid = UnitGUID("target") or nil
		if npcGuid then
			local void, void, void, void, void, npcID = strsplit("-", npcGuid)
			if npcID then
				-- Ignore specific NPCs for selecting, accepting and turning-in quests (required if automation has consequences)
				if npcID == "45400" 	-- Fiona's Caravan (Eastern Plaguelands)
				or npcID == "18166" 	-- Khadgar (Allegiance to Aldor/Scryer, Shattrath)
				or npcID == "114719" 	-- Trader Caelen (Obliterum Forge, Dalaran, Broken Isles)
				or npcID == "6294" 		-- Krom Stoutarm (Heirloom Curator, Ironforge)
				or npcID == "6566" 		-- Estelle Gendry (Heirloom Curator, Undercity)
				then
					return true
				end
				-- Ignore specific NPCs for selecting quests only (required if incomplete quest turn-ins are selected automatically)
				if actionType == "Select" then
					if npcID == "15192" 	-- Anachronos (Caverns of Time)
					or npcID == "111243" 	-- Archmage Lan'dalock (Seal quest, Dalaran)
					or npcID == "119388" 	-- Chieftain Hatuun (Krokul Hovel, Krokuun)
					or npcID == "87391" 	-- Fate-Twister Seress (Seal quest, Stormshield)
					or npcID == "88570"		-- Fate-Twister Tiklal (Seal quest, Horde)
					or npcID == "87706" 	-- Gazmolf Futzwangler (Reputation quests, Nagrand, Draenor)
					or npcID == "55402" 	-- Korgol Crushskull (Darkmoon Faire, Pit Master)
					or npcID == "70022" 	-- Ku'ma (Isle of Giants, Pandaria)
					or npcID == "12944" 	-- Lokhtos Darkbargainer (Thorium Brotherhood, Blackrock Depths)
					or npcID == "109227" 	-- Meliah Grayfeather (Tradewind Roost, Highmountain)
					or npcID == "99183" 	-- Renegade Ironworker (Tanaan Jungle, repeatable quest)
					or npcID == "87393" 	-- Sallee Silverclamp (Reputation quests, Nagrand, Draenor)
					then
						return true
					end
				end
			end
		end
	end

	-- Function to check if quest requires currency
	local function QuestRequiresCurrency()
		for i = 1, 6 do
			local progItem = _G["QuestProgressItem" ..i] or nil
			if progItem and progItem:IsShown() and progItem.type == "required" and progItem.objectType == "currency" then
				return true
			end
		end
	end

	-- Function to check if quest requires gold
	local function QuestRequiresGold()
		local goldRequiredAmount = GetQuestMoneyToGet()
		if goldRequiredAmount and goldRequiredAmount > 0 then
			return true
		end
	end

	-- Register events
	local qFrame = CreateFrame("FRAME")
	qFrame:RegisterEvent("QUEST_DETAIL")
	qFrame:RegisterEvent("QUEST_ACCEPT_CONFIRM")
	qFrame:RegisterEvent("QUEST_PROGRESS")
	qFrame:RegisterEvent("QUEST_COMPLETE")
	qFrame:RegisterEvent("QUEST_GREETING")
	qFrame:RegisterEvent("QUEST_AUTOCOMPLETE")
	qFrame:RegisterEvent("GOSSIP_SHOW")
	qFrame:RegisterEvent("QUEST_FINISHED")
	qFrame:SetScript("OnEvent", function(self, event)

		-- Clear progress items when quest interaction has ceased
		if event == "QUEST_FINISHED" then
			for i = 1, 6 do
				local progItem = _G["QuestProgressItem" ..i] or nil
				if progItem and progItem:IsShown() then
					progItem:Hide()
				end
			end
			return
		end

		-- Do nothing if SHIFT key is being held
		if IsShiftKeyDown() then return end

		----------------------------------------------------------------------
		-- Accept quests automatically
		----------------------------------------------------------------------

		-- Accept quests with a quest detail window
		if event == "QUEST_DETAIL" then
			-- Don't accept blocked quests
			if isNpcBlocked("Accept") then return end
			-- Accept quest
			if QuestGetAutoAccept() then
				-- Quest has already been accepted by Wow so close the quest detail window
				CloseQuest()
			else
				-- Quest has not been accepted by Wow so accept it
				AcceptQuest()
				HideUIPanel(QuestFrame)
			end
		end

		-- Accept quests which require confirmation (such as sharing escort quests)
		if event == "QUEST_ACCEPT_CONFIRM" then
			ConfirmAcceptQuest() 
			StaticPopup_Hide("QUEST_ACCEPT")
		end

		----------------------------------------------------------------------
		-- Turn-in quests automatically
		----------------------------------------------------------------------

		-- Turn-in progression quests
		if event == "QUEST_PROGRESS" and IsQuestCompletable() then
			-- Don't continue quests for blocked NPCs
			if isNpcBlocked("Complete") then return end
			-- Don't continue if quest requires currency
			if QuestRequiresCurrency() then return end
			-- Don't continue if quest requires gold
			if QuestRequiresGold() then return end
			-- Continue quest
			CompleteQuest()
		end

		-- Turn in completed quests if only one reward item is being offered
		if event == "QUEST_COMPLETE" then
			-- Don't complete quests for blocked NPCs
			if isNpcBlocked("Complete") then return end
			-- Don't complete if quest requires currency
			if QuestRequiresCurrency() then return end
			-- Don't complete if quest requires gold
			if QuestRequiresGold() then return end
			-- Complete quest
			if GetNumQuestChoices() <= 1 then
				GetQuestReward(GetNumQuestChoices())
			end
		end

		-- Show quest dialog for quests that use the objective tracker (it will be completed automatically)
		-- if event == "QUEST_AUTOCOMPLETE" then
		-- 	LeaPlusLC.PopupQuestTicker = C_Timer.NewTicker(0.25, PopupQuestComplete, 20)
		-- end

		----------------------------------------------------------------------
		-- Select quests automatically
		----------------------------------------------------------------------

		if event == "GOSSIP_SHOW" or event == "QUEST_GREETING" then

			-- Select quests
			if UnitExists("npc") or QuestFrameGreetingPanel:IsShown() or GossipFrameGreetingPanel:IsShown() then

				-- Don't select quests for blocked NPCs
				if isNpcBlocked("Select") then return end

				-- Select quests
				if event == "QUEST_GREETING" then
					-- Quest greeting
					local availableCount = GetNumAvailableQuests() + GetNumActiveQuests()
					if availableCount >= 1 then
						for i = 1, availableCount do
							if _G["QuestTitleButton" .. i].isActive == 0 then
								-- Select available quests
								C_Timer.After(0.01, function() SelectAvailableQuest(_G["QuestTitleButton" .. i]:GetID()) end)
							else
								-- Select completed quests
								local void, isComplete = GetActiveTitle(i)
								if isComplete then
									SelectActiveQuest(_G["QuestTitleButton" .. i]:GetID())
								end
							end
						end
					end
				else
					-- Gossip frame
					local availableCount = GetNumGossipAvailableQuests() + GetNumGossipActiveQuests()
					if availableCount >= 1 then
						for i = 1, availableCount do
							if _G["GossipTitleButton" .. i].type == "Available" then
								-- Select available quests
								C_Timer.After(0.01, function() SelectGossipAvailableQuest(i) end)
							else
								-- Select completed quests
								local isComplete = select(i * 6 - 5 + 3, GetGossipActiveQuests()) -- 4th argument of 6 argument line
								if isComplete then
									if _G["GossipTitleButton" .. i].type == "Active" then
										SelectGossipActiveQuest(_G["GossipTitleButton" .. i]:GetID())
									end
								end
							end
						end
					end
				end
			end
		end
	end)
end

function Interface:Mover()
	function Interface:CreateOwnHandleFrame(frame, width, height, offX, offY, name)
	 local handle = CreateFrame("Frame", "Moverhandle"..name)
	 handle:SetWidth(width)
	 handle:SetHeight(height)
	 handle:SetParent(frame)
	 handle:EnableMouse(true)
	 handle:SetMovable(true)
	 handle:SetPoint("TOPLEFT", frame ,"TOPLEFT", offX, offY)
	 return handle
	end

	local function OnDragStart(self)
	 local frameToMove = self.frameToMove
	 if frameToMove:IsMovable() then
	    frameToMove:StartMoving()
	    frameToMove.isMoving = true
	  end
	end

	local function OnDragStop(self)
	 local frameToMove = self.frameToMove
	 frameToMove:StopMovingOrSizing()
	 frameToMove.isMoving = false
	end

	function Interface:CreateQuestTrackerHandle()
	 local handle = CreateFrame("Frame", "MoverhandleQuestTracker")
	 handle:SetParent(ObjectiveTrackerFrame)
	 handle:EnableMouse(true)
	 handle:SetMovable(true)
	 handle:SetAllPoints(ObjectiveTrackerFrame.HeaderMenu.Title)

	 ObjectiveTrackerFrame.BlocksFrame.QuestHeader:EnableMouse(true)
	 ObjectiveTrackerFrame.BlocksFrame.AchievementHeader:EnableMouse(true)
	 ObjectiveTrackerFrame.BlocksFrame.ScenarioHeader:EnableMouse(true)
	 return handle
	end

	function Interface:SetMoveHandle(frameToMove, handle)
	 if not frameToMove then
	  return
	 end
	 if not handle then handle = frameToMove end
	 handle.frameToMove = frameToMove

	 if not frameToMove.EnableMouse then return end
	 frameToMove:SetMovable(true)
	 handle:RegisterForDrag("LeftButton");

	 handle:SetScript("OnDragStart", OnDragStart)
	 handle:SetScript("OnDragStop", OnDragStop)
	end

	local movableFrames = {
	 BankFrame,
	 DressUpFrame,
	 FriendsFrame,
	 GameMenuFrame,
	 GossipFrame,
	 HelpFrame,
	 InterfaceOptionsFrame,
	 LootFrame,
	 MailFrame,
	 MerchantFrame,
	 PVEFrame,
	 QuestFrame,
	 QuestLogPopupDetailFrame,
	 RaidBrowserFrame,
	 SpellBookFrame,
	 SUFWrapperFrame,
	 TradeFrame,
	 VideoOptionsFrame
	}

	local movableFramesWithhandle = {
	 ["CharacterFrame"] =  { PaperDollFrame, fff, ReputationFrame, TokenFrame , PetPaperDollFrameCompanionFrame, ReputationFrame } ,
	 ["ColorPickerFrame"] = { Interface:CreateOwnHandleFrame(ColorPickerFrame, 132, 32, 117, 8, "ColorPickerFrame") },
	 ["MailFrame"] = {SendMailFrame},
	 ["WorldMapFrame"] = { WorldMapFrame },
	}

	local movableFramesLoD = {
	 ["Blizzard_AchievementUI"] = function() Interface:SetMoveHandle(AchievementFrame, AchievementFrameHeader) end,
	 ["Blizzard_ArchaeologyUI"] = function() Interface:SetMoveHandle(ArchaeologyFrame) end,
	 ["Blizzard_AuctionUI"] = function() Interface:SetMoveHandle(AuctionFrame) end,
	 ["Blizzard_BarbershopUI"] = function() Interface:SetMoveHandle(BarberShopFrame) end,
	 ["Blizzard_BindingUI"] = function() Interface:SetMoveHandle(KeyBindingFrame) end,
	 ["Blizzard_Calendar"] = function() Interface:SetMoveHandle(CalendarFrame) end,
	 ["Blizzard_Collections"] = function() Interface:SetMoveHandle(CollectionsJournal); Interface:SetMoveHandle(WardrobeFrame) end,
	 ["Blizzard_EncounterJournal"] = function() Interface:SetMoveHandle(EncounterJournal, Interface:CreateOwnHandleFrame(EncounterJournal, 775, 20, 0, 0, "EncounterJournal")) end,
	 ["Blizzard_GarrisonUI"] = function() Interface:SetMoveHandle(GarrisonMissionFrame); Interface:SetMoveHandle(GarrisonCapacitiveDisplayFrame); Interface:SetMoveHandle(GarrisonLandingPage) end,
	 ["Blizzard_GuildBankUI"] = function() Interface:SetMoveHandle(GuildBankFrame) end,
	 ["Blizzard_Communities"] = function() Interface:SetMoveHandle(CommunitiesFrame) end,
	 ["Blizzard_InspectUI"] = function() Interface:SetMoveHandle(InspectFrame) end,
	 ["Blizzard_ItemAlterationUI"] = function() Interface:SetMoveHandle(TransmogrifyFrame) end,
	 ["Blizzard_ItemSocketingUI"] = function() Interface:SetMoveHandle(ItemSocketingFrame) end,
	 ["Blizzard_LookingForGuildUI"] = function() Interface:SetMoveHandle(LookingForGuildFrame) end,
	 ["Blizzard_MacroUI"] = function() Interface:SetMoveHandle(MacroFrame) end,
	 ["Blizzard_OrderHallUI"] = function() Interface:SetMoveHandle(OrderHallMissionFrame) end,
	 ["Blizzard_TalentUI"] = function()  Interface:SetMoveHandle(PlayerTalentFrame) end,
	 ["Blizzard_TrainerUI"] = function() Interface:SetMoveHandle(ClassTrainerFrame) end,
	 ["Blizzard_TradeSkillUI"] = function() Interface:SetMoveHandle(TradeSkillFrame) end,
	 ["Blizzard_VoidStorageUI"] = function() Interface:SetMoveHandle(VoidStorageFrame) end,
	 ["Blizzard_ObliterumUI"] = function() Interface:SetMoveHandle(ObliterumForgeFrame) end,
	}

	 -- ["Blizzard_ArtifactUI"]=function() DTweaks_Mover:SetMoveHandle(ArtifactFrame.ForgeBadgeFrame) end,
	 
	function movableFramesLoD:Interface()
	 for _, frame in pairs(movableFrames) do
	   Interface:SetMoveHandle(frame)
	 end

	 for frame, handles in pairs(movableFramesWithhandle) do
	   for index, handle in pairs(handles) do
	     Interface:SetMoveHandle(_G[frame],handle)
	   end
	 end
	end

	local frame = CreateFrame("Frame")
	frame:SetScript("OnEvent", ADDON_LOADED)
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", function(self, event, addonName)
		if movableFramesLoD[addonName] then movableFramesLoD[addonName]() end
		movableFramesLoD:Interface()
	end)
end

function Interface:Skin()

	--CharacterFrame
	for i, v in pairs(
		{
			--ActionBars
			MainMenuBarArtFrameBackground.BackgroundLarge,
			MainMenuBarArtFrame.LeftEndCap,
			MainMenuBarArtFrame.RightEndCap,
			--PlayerFrames
			PlayerFrameTexture,
			PetFrameTexture,
			CastingBarFrame.Border,
			TargetFrameTextureFrameTexture,
			TargetFrameToTTextureFrameTexture,
			TargetFrameSpellBar.Border,
			FocusFrameTextureFrameTexture,
			FocusFrameToTTextureFrameTexture,
			FocusFrameSpellBar.Border,
			--BossFrames
			Boss1TargetFrameTextureFrameTexture,
			Boss2TargetFrameTextureFrameTexture,
			Boss3TargetFrameTextureFrameTexture,
			Boss4TargetFrameTextureFrameTexture,
			Boss5TargetFrameTextureFrameTexture,
			--Minimap
			MinimapBorder,
			--Exp bar
			StatusTrackingBarManager.SingleBarLarge,
			StatusTrackingBarManager.SingleBarLargeUpper,
		}
	) do
		v:SetVertexColor(.25, .25, .25)
	end

	for i = 1, 12 do
		local button = _G["ActionButton"..i]
		local buttonRight = _G["MultiBarBottomRightButton"..i]
		local buttonLeft = _G["MultiBarBottomLeftButton"..i]

		local barRight = _G["MultiBarRightButton"..i]
		local barLeft = _G["MultiBarLeftButton"..i]

		button.Border:SetTexture(nil)
		button.FlyoutBorderShadow:SetTexture(nil)
		button.FlyoutBorder:SetTexture(nil)
		button.NormalTexture:SetTexture(nil)

		buttonRight.Border:SetTexture(nil)
		buttonRight.FlyoutBorderShadow:SetTexture(nil)
		buttonRight.FlyoutBorder:SetTexture(nil)
		buttonRight.NormalTexture:SetTexture(nil)

		buttonLeft.Border:SetTexture(nil)
		buttonLeft.FlyoutBorderShadow:SetTexture(nil)
		buttonLeft.FlyoutBorder:SetTexture(nil)
		buttonLeft.NormalTexture:SetTexture(nil)

		barRight.Border:SetTexture(nil)
		barRight.FlyoutBorderShadow:SetTexture(nil)
		barRight.FlyoutBorder:SetTexture(nil)
		barRight.NormalTexture:SetTexture(nil)

		barLeft.Border:SetTexture(nil)
		barLeft.FlyoutBorderShadow:SetTexture(nil)
		barLeft.FlyoutBorder:SetTexture(nil)
		barLeft.NormalTexture:SetTexture(nil)
	end
end

function Interface:RaidFrame()

	--//User Options

	local iconCount = 3
	local iconScale = 1.2
	local iconAlpha = 0.9
	local iconPosition = "TOP"
	local growDirection = "RIGHT"
	local showCooldownNumbers = false
	local cooldownNumberScale = 0.5

	--[[ Notes
	iconCount: Number of icons you want to display (per frame).
	iconScale: The scale of the icon based on the size of the default icons on raidframe.
	iconAlpha: Icon transparency.
	iconPosition: "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "TOP", "BOTTOM", "RIGHT", "LEFT", "CENTER", "HIGHCENTER"
	growDirection:"DOWN", "UP", "LEFT", "RIGHT"
	showCooldownNumbers: Show or hide cooldown text (must have it enabled in blizzard settings or use an addon).
	cooldownNumberScale: Scale the icon's cooldown text size.
	]]

	local spellList = {
		--Death Knight
		48707,  --Anti-Magic Shell
		48792,  --Icebound Fortitude
		55233,  --Vampiric Blood
		194679, --Rune Tap
		145629, --Anti-Magic Zone
		81256,  --Dancing Rune Weapon

		--Demon Hunter
		196555, --Netherwalk
		187827, --Metamorphosis (Vengeance)
		212800, --Blur

		--Druid
		102342, --Ironbark
		22812,  --Barkskin
		61336,  --Survival Instincts
		5215,   --Prowl

		--Hunter
		186265, --Aspect of the Turtle
		53480,  --Roar of Sacrifice
		264735, --Survival of the Fittest (Pet Ability)
		281195, --Survival of the Fittest (Lone Wolf)

		--Mage
		45438,  --Ice Block
		198111, --Temporal Shield
		198144, --Ice Form

		--Monk
		125174, --Touch of Karma
		120954, --Fortifying Brew (Brewmaster)
		243435, --Fortifying Brew (Mistweaver)
		201318, --Fortifying Brew (Windwalker)
		115176, --Zen Meditation
		116849, --Life Cocoon
		122278, --Dampen Harm
		122783, --Diffuse Magic

		--Paladin
		642,    --Divine Shield
		1022,   --Blessing of Protection
		204018, --Blessing of Spellwarding
		498,    --Divine Protection
		31850,  --Ardent Defender
		86659,  --Guardian of Ancient Kings

		--Priest
		47788,  --Guardian Spirit
		47585,  --Dispersion
		33206,  --Pain Suppression
		81782,  --Power Word: Barrier
		271466, --Luminous Barrier

		--Rogue
		31224,  --Cloak of Shadows
		5277,   --Evasion
		199754, --Riposte
		45182,  --Cheating Death
		1784,   --Stealth

		--Shaman
		210918, --Ethereal Form
		108271, --Astral Shift

		--Warlock
		104773, --Unending Resolve
		108416, --Dark Pact

		--Warrior
		118038, --Die by the Sword
		184364, --Enraged Regeneration
		871,    --Shield Wall
		97463,  --Rallying Cry
		12975,  --Last Stand

		--Other
		"Food",
		"Drink",
		"Food & Drink",
		"Refreshment",
	}

	local buffs = {}
	local overlays = {}

	for k, v in ipairs(spellList) do
	    buffs[v] = k
	end

	--Anchor Settings
	if iconPosition == "HIGHCENTER" then
	    anchor = "BOTTOM"
	    iconPosition = "CENTER"
	else
	    anchor = iconPosition
	end

	hooksecurefunc("CompactUnitFrame_UpdateBuffs", function(self)
	    if self:IsForbidden() or not self:IsVisible() or not self.buffFrames then
	        return
	    end

	    local unit = self.displayedUnit
	    local frame = self:GetName() .. "BuffOverlay"
	    local index = 1
	    local overlayNum = 1

	    for i = 1, iconCount do
	        local overlay = overlays[frame .. i]
	        if not overlay then
	            if not self or not unit then return end
	            overlay = _G[frame .. i] or CreateFrame("Button", frame .. i, self, "CompactAuraTemplate")
	            overlay.cooldown:SetHideCountdownNumbers(not showCooldownNumbers)
	            overlay.cooldown:SetScale(cooldownNumberScale)
	            overlay:ClearAllPoints()
	            if i == 1 then
	                overlay:SetPoint(anchor, self, iconPosition)
	            else
	                if growDirection == "DOWN" then
	                    overlay:SetPoint("TOP", _G[frame .. i - 1], "BOTTOM")
	                elseif growDirection == "LEFT" then
	                    overlay:SetPoint("BOTTOMRIGHT", _G[frame .. i - 1], "BOTTOMLEFT")
	                elseif growDirection == "UP" then
	                    overlay:SetPoint("BOTTOM", _G[frame .. i - 1], "TOP")
	                else
	                    overlay:SetPoint("BOTTOMLEFT", _G[frame .. i - 1], "BOTTOMRIGHT")
	                end
	            end
	            overlay:SetScale(iconScale)
	            overlay:SetAlpha(iconAlpha)
	            overlay:EnableMouse(false)
	            overlay:RegisterForClicks()
	            overlays[frame .. i] = overlay
	        end
	        overlay:Hide()
	    end

	    while overlayNum <= iconCount do
	        local buffName, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, index)
	        if spellId then
	            if buffs[buffName] and not buffs[spellId] then
	                buffs[spellId] = buffs[buffName]
	            end
	            
	            if buffs[spellId] then
	                CompactUnitFrame_UtilSetBuff(overlays[frame .. overlayNum], unit, index, nil)
	                overlays[frame .. overlayNum]:SetSize(self.buffFrames[1]:GetSize())
	                overlayNum = overlayNum + 1
	            end
	        else
	            break
	        end
	        index = index + 1
	    end
	end)
end

function Interface:BossFrame()

	-- initialize addon table
	Interface.events = Interface.events or {}
	Interface.commands = Interface.commands or {}

	local db

	local BF = {
		space = -10, -- vertical space
	}

	Interface.anchorFrame = Interface.anchorFrame or CreateFrame("Frame", nil, _G.UIParent)

	local events = Interface.events
	local commands = Interface.commands
	local anchorFrame = Interface.anchorFrame
	local frames = {}

	local function InterfaceSpellBar_OnSetPoint(self)
		-- if self.boss then
		-- 	if _G["Boss"..i.."TargetFrameBuff1"] then
		-- 		self:SetPoint("TOP", self:GetParent(), "BOTTOM", 5.5, 65)
		-- 	elseif _G["Boss"..i.."TargetFrameDebuff1"] and not _G["Boss"..i.."TargetFrameBuff1"] then
		-- 		self:SetPoint("TOP", self:GetParent(), "BOTTOM", 5.5, 44)
		-- 	else
		-- 		self:SetPoint("TOP", self:GetParent(), "BOTTOM", 5.5, 26.5)
		-- 	end
		-- end
	end

	local function Interfaces_SetStyle()
		local p
		for i = 1, MAX_BOSS_FRAMES do
			local boss = _G["Boss"..i.."TargetFrame"]
			local bossPortrait = _G["Boss"..i.."TargetFramePortrait"]
			local bossTexture = _G["Boss"..i.."TargetFrameTextureFrameTexture"]
			local bossSpellBar = _G["Boss"..i.."TargetFrameSpellBar"]

			boss:SetScale(1)-- taint

			boss.highLevelTexture:SetPoint("CENTER", 62, -16);
			boss.threatIndicator:SetTexture(nil)

			if BF.space and i > 1 and boss:GetNumPoints() > 0 then
				p = {boss:GetPoint(1)}
				p[5] = BF.space
				boss:ClearAllPoints() -- taint
				boss:SetPoint(unpack(p)) -- taint
			end

			boss.raidTargetIcon:SetPoint("CENTER", frameBorder, "LEFT", -3, 0)

			boss.name:SetPoint("BOTTOM", boss.healthbar, "TOP", 0, 4)
			boss.highLevelTexture:SetPoint("CENTER", 62, -16);

			boss.deadText:SetPoint("CENTER", boss.healthbar, "CENTER", 0, 0);
			boss.unconsciousText:SetPoint("CENTER", boss.healthbar, "CENTER", 0, 0);
			boss.nameBackground:Hide()

			local frame = CreateFrame("Frame", nil, boss)
			frame:SetHeight(64)
			frame:SetWidth(64)
			frame:SetPoint("TOPRIGHT", boss, "TOPRIGHT", -42, -12)

			portrait = frame:CreateTexture(nil, "BACKGROUND")
			portrait:SetHeight(64)
			portrait:SetWidth(64)
			portrait:SetPoint("TOPLEFT", 0, 0)

			local frameBorder = CreateFrame("Frame", nil, boss)
			local borderFrameLevel = frameBorder:GetFrameLevel()
			boss.textureFrame:SetFrameLevel(borderFrameLevel + 1)
			bossTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
			_G["Boss"..i.."TargetFrameDropDown"]:SetFrameLevel(borderFrameLevel + 1)
			frameBorder:SetPoint("TOPLEFT", boss.Background, "TOPLEFT", -4, 3)
			frameBorder:SetPoint("BOTTOMRIGHT", boss.Background, "BOTTOMRIGHT", 4, -5)
		end
		wipe(p)
		hooksecurefunc("Target_Spellbar_AdjustPosition", InterfaceSpellBar_OnSetPoint)
	end

	hooksecurefunc("BossTargetFrame_OnLoad", function(self, unit, event)
		self.maxBuffs = 3;
		self.maxDebuffs = 3;
		self.levelText:SetPoint("CENTER", 62, select(5, self.levelText:GetPoint("CENTER")));
	end)

	local function Interfaces_SetScale(scale)
		for i = 1, MAX_BOSS_FRAMES do
			_G["Boss"..i.."TargetFrame"]:SetScale(scale)
		end
	end

	function Interface:Enable()
		Interfaces_SetStyle()

		self.bossFrame = _G["Boss1TargetFrame"]
		self.defaultScale = self.bossFrame:GetScale()
		self.bossFrame.OrgSetPoint = self.bossFrame.SetPoint
		self.bossFrame.SetPoint = function() end
		self.bossFrame:HookScript("OnHide", function() anchorFrame:Hide() end)

		anchorFrame:SetMovable(true)
		anchorFrame:SetScale(self.defaultScale)
		anchorFrame:SetSize(self.bossFrame:GetWidth(), self.bossFrame:GetHeight() * 5 - (BF.space * 4))
		anchorFrame:SetScript("OnMouseDown", anchorFrame.OnMouseDown)
		anchorFrame:SetScript("OnMouseUp", anchorFrame.OnMouseUp)
		anchorFrame:SetScript("OnDragStop", anchorFrame.OnMouseUp)
		anchorFrame:SetScript("OnUpdate", anchorFrame.OnUpdate)
		anchorFrame:SetScript("OnMouseWheel", anchorFrame.OnMouseWheel)
		anchorFrame:SetScript("OnShow", anchorFrame.OnShow)
		anchorFrame:Hide()
		if Interface.settings.BossFrame then
			anchorFrame:ClearAllPoints()
			anchorFrame:SetPoint(unpack(Interface.settings.BossFrame))
			self.bossFrame:ClearAllPoints() -- taint
			self.bossFrame:OrgSetPoint(unpack(Interface.settings.BossFrame)) -- taint
		else
			anchorFrame:ClearAllPoints()
			anchorFrame:SetPoint(unpack(Interface.settings.BossFrame))
			self.bossFrame:ClearAllPoints() -- taint
			self.bossFrame:OrgSetPoint(unpack(Interface.settings.BossFrame)) -- taint
		end

		self.testMode = false
	end

	function Interface:UnregisterEvent(...)
		anchorFrame:UnregisterEvent(...)
	end

	function anchorFrame:OnMouseDown(button)
		if button == "LeftButton" then
			self.moving = true
			self:StartMoving()
		end
	end

	function anchorFrame:OnMouseUp(button)
		if button == "LeftButton" then
			self.moving = false
			self:StopMovingOrSizing()
		end
	end

	function anchorFrame:OnUpdate(elapsed)
		if not InCombatLockdown() and self.moving then
			Interface.settings.BossFrame = {self:GetPoint(1)}
			Interface.bossFrame:ClearAllPoints()
			Interface.bossFrame:OrgSetPoint(unpack(Interface.settings.BossFrame))
		end
	end

	function anchorFrame:OnShow()
		if not self.bkgndFrame then
			self.bkgndFrame = CreateFrame("Frame", nil, self)
			self.bkgndFrame:SetFrameStrata("DIALOG")
			self.bkgndFrame:SetBackdrop({
				bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
			})
			self.bkgndFrame:SetAllPoints(self)
			self.bkgndFrame:SetBackdropColor(0, 0.75, 0, 0.5)
		end
		self:EnableMouse(true)
		self:EnableMouseWheel(true)
		self:SetBackdrop({
			edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
			tile = true,
			edgeSize = 14,
			tileSize = 16,
			insets = {left = 3, right = 3, top = 3, bottom = 3},
		})
		self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
	end

	function events:PLAYER_LOGIN(...)
		self:UnregisterEvent("PLAYER_LOGIN")
		self:UnregisterEvent("SPELLS_CHANGED")

		self:Enable()
	end
	events.SPELLS_CHANGED = events.PLAYER_LOGIN

	function events:PLAYER_REGEN_DISABLED()
		if anchorFrame:IsShown() then
			anchorFrame:Hide()
		end
		Interface.testMode = false
	end

	local MAX_BUFFS = 6;
	local MAX_DEBUFFS = 12;

	local function UpdateBuffAnchor(self, buffName, index, numDebuffs, newRow, startX, startY)
		local buff = _G[buffName..index];
		
		if ( index == 1 ) then
			if ( numDebuffs > 0 ) then
				-- XarBar.db.profile.buffsOnTop is true or there are no debuffs... buffs start on top
				buff:SetPoint("TOPLEFT", self, "BOTTOMLEFT", startX, startY-23);
			else
				buff:SetPoint("TOPLEFT", self, "BOTTOMLEFT", startX, startY);
			end
		elseif ( newRow ) then
			buff:SetPoint("TOPLEFT", _G[buffName..(index - 6)], "BOTTOMLEFT", 0, -3);
		else
			buff:SetPoint("TOPLEFT", _G[buffName..(index - 1)], "TOPRIGHT", 3, 0);
		end

		-- Resize
		buff:SetWidth(17);
		buff:SetHeight(17);
	end

	local function UpdateDebuffAnchor(self, debuffName, index, numBuffs, newRow, startX, startY)
		local debuff = _G[debuffName..index];

		if ( index == 1 ) then
			debuff:SetPoint("TOPLEFT", self, "BOTTOMLEFT", startX, startY);
			--DebuffsFrame:SetPoint("TOPLEFT", debuff, "TOPLEFT", 0, 0);
			--DebuffsFrame:SetPoint("BOTTOMLEFT", debuff, "BOTTOMLEFT", 0, -3);
		elseif ( newRow ) then
			debuff:SetPoint("TOPLEFT", _G[debuffName..(index - 6)], "BOTTOMLEFT", 0, -3);
		else
			debuff:SetPoint("TOPLEFT", _G[debuffName..(index - 1)], "TOPRIGHT", 3 + 1, 0);
		end

		-- Resize
		debuff:SetWidth(21);
		debuff:SetHeight(21);
		
		local debuffFrame =_G[debuffName..index.."Border"];
		debuffFrame:SetWidth(21+2);
		debuffFrame:SetHeight(21+2);
	end

	local function UpdateAuraPositions(self, auraName, numAuras, numOppositeAuras, updateFunc)
		local startX, startY;
		startX, startY = 4, 32;

		-- current width of a row, increases as auras are added and resets when a new aura's width exceeds the max row width
		local rowSize = 0;
		for i=1, numAuras do
			-- anchor the current aura
			if ( i == 1 ) then
				rowSize = 1;
			else
				rowSize = rowSize + 1;
			end
			if ( rowSize > 6 ) then
				-- this aura would cause the current row to exceed the max row size, so make this aura
				-- the start of a new row instead
				rowSize = 1;
				updateFunc(self, auraName, i, numOppositeAuras, true, startX, startY);
			else
				updateFunc(self, auraName, i, numOppositeAuras, false, startX, startY);
			end
		end
	end

	local function UpdateAuras(bossID)
		local self = _G["Boss"..bossID.."TargetFrame"];
		local frame, frameName;
		local frameIcon, frameCount, frameCooldown;
		local numBuffs = 0;

		if not UnitExists("boss"..bossID) then return end
		
		for i = 1, 6 do
			local buffName, icon, count, _, duration, expirationTime = UnitBuff(self.unit, i, nil);
			if ( buffName ) then
				frameName = "Boss"..bossID.."TargetFrameBuff"..(i);
				frame = _G[frameName];
				if ( not frame ) then
					if ( not icon ) then
						break;
					else
						frame = CreateFrame("Button", frameName, self, "TargetBuffFrameTemplate");
						frame.unit = self.unit;
					end
				end
				if ( icon ) then
					frame:SetID(i);
					
					-- set the icon
					frameIcon = _G[frameName.."Icon"];
					frameIcon:SetTexture(icon);
					
					-- set the count
					frameCount = _G[frameName.."Count"];
					if ( count > 1 ) then
						frameCount:SetText(count);
						frameCount:Show();
					else
						frameCount:Hide();
					end
					
					-- Handle cooldowns
					frameCooldown = _G[frameName.."Cooldown"];
					CooldownFrame_Set(frameCooldown, expirationTime - duration, duration, duration > 0, true);
					
					numBuffs = numBuffs + 1;

					frame:ClearAllPoints();
					frame:Show();
				else
					frame:Hide();
				end
			else
				break;
			end
		end
		
		for i = numBuffs + 1, MAX_BUFFS do
			local frame = _G["Boss1TargetFrameBuff"..i];
			if ( frame ) then
				frame:Hide();
			else
				break;
			end
		end
		
		local color;
		local frameBorder;
		local numDebuffs = 0;
		
		for i = 1, 12 do
			local debuffName, icon, count, debuffType, duration, expirationTime, caster, _, _, _, _, isBossDebuff = UnitDebuff(self.unit, i, nil);
			if ( debuffName ) and (caster == "player" or isBossDebuff) then
				frameName = "Boss"..bossID.."TargetFrameDebuff"..(i);
				frame = _G[frameName];
				if ( not frame ) then
					if ( not icon ) then
						break;
					else
						frame = CreateFrame("Button", frameName, self, "TargetDebuffFrameTemplate");
						frame.unit = self.unit;
					end
				end
				if ( icon ) then
					frame:SetID(i);
					
					-- set the icon
					frameIcon = _G[frameName.."Icon"];
					frameIcon:SetTexture(icon);
					
					-- set the count
					frameCount = _G[frameName.."Count"];
					if ( count > 1 ) then
						frameCount:SetText(count);
						frameCount:Show();
					else
						frameCount:Hide();
					end
					
					-- Handle cooldowns
					frameCooldown = _G[frameName.."Cooldown"];
					CooldownFrame_Set(frameCooldown, expirationTime - duration, duration, duration > 0, true);
					
					-- set debuff type color
					if ( debuffType ) then
						color = DebuffTypeColor[debuffType];
					else
						color = DebuffTypeColor["none"];
					end
					frameBorder = _G[frameName.."Border"];
					frameBorder:SetVertexColor(color.r, color.g, color.b);
					
					numDebuffs = numDebuffs + 1;

					frame:ClearAllPoints();
					frame:Show();
				else
					frame:Hide();
				end
			else
				break;
			end
		end
		
		for i = numDebuffs + 1, MAX_DEBUFFS do
			local frame = _G["Boss"..bossID.."TargetFrameDebuff"..i];
			if ( frame ) then
				frame:Hide();
			else
				break;
			end
		end
		
		-- update buff positions
		UpdateAuraPositions(self, "Boss"..bossID.."TargetFrameBuff", numBuffs, numDebuffs, UpdateBuffAnchor);
		
		-- update debuff positions
		UpdateAuraPositions(self, "Boss"..bossID.."TargetFrameDebuff", numDebuffs, numBuffs, UpdateDebuffAnchor);
	end

	function events:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
		events:PLAYER_REGEN_DISABLED()
		-- -- --
		for i = 1, MAX_BOSS_FRAMES do
			local boss = _G["Boss"..i.."TargetFrame"]
			local healthBar = _G["Boss"..i.."TargetFrameHealthBar"]
			local portrait = _G["Boss"..i.."TargetFramePortrait"]

			

			if not UnitIsFriend("player", "boss"..i) then
				healthBar:SetStatusBarColor(0.8, 0.3, 0.22)
			else
				healthBar:SetStatusBarColor(0, 1, 0)
			end
			SetPortraitTexture(portrait, "boss"..i)

			UpdateAuras("boss"..i)	
		end
		for i = 1, #frames do
			frames[i].value = nil
			frames[i].elapsed = 1
		end
	end

	function events:UNIT_AURA(self, unit)
		if unit:find("boss") then
			local bossID = strsub(unit, 5)
			UpdateAuras(bossID)
		end	
	end

	local function BossColor()
		for i = 1, MAX_BOSS_FRAMES do
			local boss = _G["Boss"..i.."TargetFrame"]
			local healthBar = _G["Boss"..i.."TargetFrameHealthBar"]

			if not UnitIsFriend("player", "boss"..i) then
				healthBar:SetStatusBarColor(0.8, 0.3, 0.22)
			else
				healthBar:SetStatusBarColor(0, 1, 0)
			end
		end
	end

	hooksecurefunc("HealthBar_OnValueChanged", function(self)
		if Boss1TargetFrame:IsShown() then
			BossColor()
		end
	end)

	hooksecurefunc("BossTargetFrame_UpdateLevelTextAnchor", function(self, targetLevel)
		if ( targetLevel >= 100 ) then
			self.levelText:SetPoint("CENTER", 61, -16);
			self.highLevelTexture:SetPoint("CENTER", 61, -16);
		else
			self.levelText:SetPoint("CENTER", 62, -16);
			self.highLevelTexture:SetPoint("CENTER", 61, -16);
		end
	end)

	local function RandomFactionColor()
		local colors = {
			RED_FONT_COLOR,
			GREEN_FONT_COLOR,
			YELLOW_FONT_COLOR,
			ORANGE_FONT_COLOR
		}
		local c = colors[random(1, 4)]
		return c.r, c.g, c.b
	end

	local function BossFrameTest()
		if InCombatLockdown() then return end
		local shown = anchorFrame:IsShown()
		Interface.testMode = not shown
		for i = 1, MAX_BOSS_FRAMES do
			local b = "Boss"..i.."TargetFrame"
			if shown then
				_G[b]:Hide()
				anchorFrame:Hide()
			else
				SetPortraitTexture(_G[b.."Portrait"], "player")
				_G[b.."TextureFrameName"]:SetText("Boss"..i.."Name")
				_G[b.."NameBackground"]:SetVertexColor(RandomFactionColor())
				_G[b.."HealthBar"]:SetMinMaxValues(1, 99999999)
				_G[b.."HealthBar"]:SetValue(random(11111111, 88888888))
				_G[b.."ManaBar"]:SetMinMaxValues(1, 100)
				_G[b.."ManaBar"]:SetValue(random(15, 85))
				_G[b.."ManaBar"]:SetStatusBarColor(0.2, 0.2, 1)
				_G[b]:Show()
				anchorFrame:Show()
			end
		end
		for i = 1, #frames do
			Text_Refresh(frames[i])
		end
	end

	do
		SLASH_SIMPLEBOSS1 = "/bossframe"
		SlashCmdList.SIMPLEBOSS = function()
			BossFrameTest()
		end

		anchorFrame:SetScript("OnEvent", function(self, event, ...)
			events[event](Interface, event, ...)
		end)
		for event, func in pairs(events) do
			if type(func) == "function" then 
				anchorFrame:RegisterEvent(event) 
			end
		end
	end
end