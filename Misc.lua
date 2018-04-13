local _, JokUI = ...
local Misc = JokUI:RegisterModule("Miscellaneous")

local features = {}

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------

local misc_defaults = {
	profile = {}
}

local misc_config = {
	title = {
		type = "description",
		name = "|cff64b4ffMiscellaneous",
		fontSize = "large",
		order = 0,
	},
	desc = {
		type = "description",
		name = "Various useful options.\n",
		fontSize = "medium",
		order = 1,
	},
}

-------------------------------------------------------------------------------
-- Life-cycle
-------------------------------------------------------------------------------

function Misc:OnInitialize()
	self.db = JokUI.db:RegisterNamespace("Miscellaneous", misc_defaults)
	self.settings = self.db.profile
	JokUI.Config:Register("Miscellaneous", misc_config, 12)

	self:RegisterEvent("ADDON_LOADED")

	Misc:AutoRep()
	Misc:RangeSpell()
	Misc:SGrid()
	Misc:ShowStats()
	Misc:HoverBind()
	Misc:TooltipID()
	Misc:SafeQueue()
end

function Misc:OnEnable()
	for name in pairs(features) do
		self:SyncFeature(name)
	end
end

do
	local order = 10
	function Misc:RegisterFeature(name, short, long, default, reload, fn)
		misc_config[name] = {
			type = "toggle",
			name = short,
			descStyle = "inline",
			desc = "|cffaaaaaa" .. long,
			width = "full",
			get = function() return Misc.settings[name] end,
			set = function(_, v)
				Misc.settings[name] = v
				Misc:SyncFeature(name)
				if reload then
					StaticPopup_Show ("ReloadUI_Popup")
				end
			end,
			order = order
		}
		misc_defaults.profile[name] = default
		order = order + 1
		features[name] = fn
	end
end

function Misc:SyncFeature(name)
	features[name](Misc.settings[name])
end

function Misc:ADDON_LOADED(event, addon)
	if addon == "Blizzard_TalkingHeadUI" then
		self:SyncFeature("TalkingHead")
	end
end

-------------------------------------------------------------------------------
-- Features
-------------------------------------------------------------------------------

do
	Misc:RegisterFeature("MaxCam",
		"Maximize camera distance",
		"Automatically reset your camera to max distance when logging in.",
		true,
		false,
		function(state)
			if state then
				C_Timer.After(0.3, function()
					SetCVar("cameraDistanceMaxZoomFactor", 2.6)
					MoveViewOutStart(50000)
				end)
			end
		end)
end

do
	local enabled = false
	Misc:RegisterFeature("TalkingHead",
		"Disable Talking Head",
		"Disables the Talking Head feature that is used for some quest and event dialogues.",
		false,
		false,
		function(state)
			if not enabled and TalkingHeadFrame_PlayCurrent then
				enabled = true
				hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
					if state then TalkingHeadFrame:Hide() end
				end)
			end
		end)
end

do
	Misc:RegisterFeature("HideOrderHallBar",
		"Disable Order Hall Command Bar",
		"Hides the information bar inside your class Order Hall.",
		true,
		false,
		function(state)
			if state then
				C_Timer.After(0.3, function()
					LoadAddOn("Blizzard_OrderHallUI")
					local b = OrderHallCommandBar
					b:UnregisterAllEvents()
					b:HookScript("OnShow", b.Hide)
					b:Hide()
				end)
			end
		end)
end

do
	Misc:RegisterFeature("FillDeleteText",
		"Automatically fills the 'DELETE' string",
		"Automatically fills the 'DELETE' string when trying to delete a rare item.",
		true,
		false,
		function(state)		
				hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(s) 
					if state then s.editBox:SetText(DELETE_ITEM_CONFIRM_STRING) end
				end)
		end)
end

do
	Misc:RegisterFeature("HideLoseControlBackground",
		"Disable Lose Control Background",
		"Hides the background on the lose control frame.",
		true,
		false,
		function(state)
			if state then
				LossOfControlFrame:ClearAllPoints() LossOfControlFrame:SetPoint("CENTER",UIParent,"CENTER",0,0)
				select(1,LossOfControlFrame:GetRegions()):SetAlpha(0)
				select(2,LossOfControlFrame:GetRegions()):SetAlpha(0) select(3,LossOfControlFrame:GetRegions()):SetAlpha(0)
			end
		end)
end

do
	Misc:RegisterFeature("PixelPerfect",
		"Set Pixel Perfect",
		"Set UI to Pixel Perfect Mode.",
		false,
		true,
		function(state)
			if state then
				Advanced_UseUIScale:Disable()
				Advanced_UIScaleSlider:Disable()
				getglobal(Advanced_UseUIScale:GetName() .. "Text"):SetTextColor(1,0,0,1)
				getglobal(Advanced_UseUIScale:GetName() .. "Text"):SetText("The 'Use UI Scale' toggle is unavailable while Pixel Perfect mode is active.")
				Advanced_UseUIScaleText:SetPoint("LEFT",Advanced_UseUIScale,"LEFT",4,-40)
				if not InCombatLockdown() then
					MinimapCluster:SetScale(1.5)
					local scale = 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")
					if scale < .64 then
						UIParent:SetScale(scale)
					else
						self:UnregisterEvent("UI_SCALE_CHANGED")
						SetCVar("uiScale", scale)
					end
				end
			end
		end)
end

do
	Misc:RegisterFeature("InCombatIcon",
		"Add 'In Combat' Icon",
		"Adds an icon next to unit frames if it's in combat.",
		true,
		true,
		function(state)
			if state then
				CTT=CreateFrame("Frame")
				CTT:SetPoint("Right",TargetFrame,0,3)
				CTT:SetSize(24,24)
				CTT.t=CTT:CreateTexture(nil,BORDER)
				CTT.t:SetAllPoints()
				CTT.t:SetTexture("Interface\\Icons\\ABILITY_DUALWIELD")
				CTT:Hide()

				local function FrameOnUpdate(self) if UnitAffectingCombat("target") then self:Show() else self:Hide() end end
				local g = CreateFrame("Frame")
				g:SetScript("OnUpdate", function(self) FrameOnUpdate(CTT) end)

				CFT=CreateFrame("Frame")
				CFT:SetPoint("Right",FocusFrame,0,3)
				CFT:SetSize(24,24)
				CFT.t=CFT:CreateTexture(nil,BORDER)
				CFT.t:SetAllPoints()
				CFT.t:SetTexture("Interface\\Icons\\ABILITY_DUALWIELD")
				CFT:Hide()

				local function FrameOnUpdate(self) if UnitAffectingCombat("focus") then self:Show() else self:Hide() end end
				local g = CreateFrame("Frame")
				g:SetScript("OnUpdate", function(self) FrameOnUpdate(CFT) end)
			end
		end)
end

-- function SetPixelPerfect(self)
-- 	if not InCombatLockdown() then
-- 		local scale = 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")
-- 		if scale < .64 then
-- 			UIParent:SetScale(scale)
-- 		else
-- 			self:UnregisterEvent("UI_SCALE_CHANGED")
-- 			SetCVar("uiScale", scale)
-- 		end
-- 	else
-- 		self:RegisterEvent("PLAYER_REGEN_ENABLED")
-- 	end

-- 	if event == "PLAYER_REGEN_ENABLED" then
-- 		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
-- 	end
-- end
-- local f = CreateFrame("Frame")
-- f:RegisterEvent("VARIABLES_LOADED")
-- f:RegisterEvent("UI_SCALE_CHANGED")
-- f:SetScript("OnEvent", SetPixelPerfect)

function Misc:AutoRep()
	local g = CreateFrame("Frame")
	g:RegisterEvent("MERCHANT_SHOW")
	g:SetScript("OnEvent", function()
		local bag, slot
		for bag = 0, 4 do
				for slot = 0, GetContainerNumSlots(bag) do
						local link = GetContainerItemLink(bag, slot)
						if link and (select(3, GetItemInfo(link)) == 0) then
								UseContainerItem(bag, slot)
						end
				end
		end

		if(CanMerchantRepair()) then
				local cost = GetRepairAllCost()
				if cost > 0 then
						local money = GetMoney()
						if IsInGuild() then
								local guildMoney = GetGuildBankWithdrawMoney()
								if guildMoney > GetGuildBankMoney() then
										guildMoney = GetGuildBankMoney()
								end
								if guildMoney > cost and CanGuildBankRepair() then
										RepairAllItems(1)
										print(format("|cfff07100Repair cost covered by G-Bank: %.1fg|r", cost * 0.0001))
										return
								end
						end
						if money > cost then
								RepairAllItems()
								print(format("|cffead000Repair cost: %.1fg|r", cost * 0.0001))
						else
								print("Not enough gold to cover the repair cost.")
						end
				end
		end
	end)

	local NEW_ITEM_VENDOR_STACK_BUY = ITEM_VENDOR_STACK_BUY
	ITEM_VENDOR_STACK_BUY = '|cffa9ff00'..NEW_ITEM_VENDOR_STACK_BUY..'|r'

	local origMerchantItemButton_OnModifiedClick = _G.MerchantItemButton_OnModifiedClick
	local function MerchantItemButton_OnModifiedClickHook(self, ...)
	origMerchantItemButton_OnModifiedClick(self, ...)

	if (IsAltKeyDown()) then
		local maxStack = select(8, GetItemInfo(GetMerchantItemLink(self:GetID())))
		local _, _, _, quantity = GetMerchantItemInfo(self:GetID())

		if (maxStack and maxStack > 1) then
			BuyMerchantItem(self:GetID(), floor(maxStack / quantity))
		end
	end
	end
	MerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClickHook
end

function Misc:RangeSpell()

	hooksecurefunc("ActionButton_OnEvent",function(self, event, ...)
		if ( event == "PLAYER_TARGET_CHANGED" ) then
			self.newTimer = self.rangeTimer
		end
	end)

	hooksecurefunc("ActionButton_UpdateUsable",function(self)
		local icon = _G[self:GetName().."Icon"]
		local valid = IsActionInRange(self.action)
		if ( valid == false ) then
			icon:SetVertexColor(1, 0.2, 0.1)
		end
	end)

	hooksecurefunc("ActionButton_OnUpdate",function(self, elapsed)
		local rangeTimer = self.newTimer
		if ( rangeTimer ) then
			rangeTimer = rangeTimer - elapsed
			if ( rangeTimer <= 0 ) then
				ActionButton_UpdateUsable(self)
				rangeTimer = TOOLTIP_UPDATE_TIME
			end
			self.newTimer = rangeTimer
		end
	end)
end

function Misc:SGrid()
	SLASH_SGRIDA1 = "/sgrid"

	local frame
	local w
	local h

	SlashCmdList["SGRIDA"] = function(msg, editbox)

		if frame then
			frame:Hide()
			frame = nil
		else

			if msg == '128' then
				w = 128
				h = 72
			elseif msg == '96' then
				w = 96
				h = 54
			elseif msg == '64' then
				w = 64
				h = 36
			elseif msg == '32' then
				w = 32
				h = 18
			else
				w = nil
				w = nil
			end

			if w == nil then
				print("Usage: '/sgrid <value>' Value options are 32/64/96/128")
			else

				local lines_w = GetScreenWidth() / w
				local lines_h = GetScreenHeight() / h

				frame = CreateFrame('Frame', nil, UIParent)
				frame:SetAllPoints(UIParent)

				for i = 0, w do
					local line_texture = frame:CreateTexture(nil, 'BACKGROUND')
					if i == w/2 then
						line_texture:SetColorTexture(1, 0, 0, 0.5)
					else
						line_texture:SetColorTexture(0, 0, 0, 0.1)
					end
					line_texture:SetPoint('TOPLEFT', frame, 'TOPLEFT', i * lines_w - 1, 0)
					line_texture:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMLEFT', i * lines_w + 1, 0)
				end

				for i = 0, h do
					local line_texture = frame:CreateTexture(nil, 'BACKGROUND')
					if i == h/2 then
						line_texture:SetColorTexture(1, 0, 0, 0.5)
					else
						line_texture:SetColorTexture(0, 0, 0, 0.5)
					end
						line_texture:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, -i * lines_h + 1)
						line_texture:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT', 0, -i * lines_h - 1)
				end
			end
		end
	end
end

function Misc:ShowStats()
	local cfg = CreateFrame("Frame")
	cfg.stats = {
	    pos1              = "TOPLEFT",
	    pos2              = 10,
	    pos3              = "TOPLEFT",
	    pos4              = -5,
	  }


	local addonList = 50
	local font = ("Fonts\\FRIZQT__.TTF")
	local fontSize = 14
	local fontFlag = 'THINOUTLINE'
	local textAlign = 'CENTER'
	local position = { cfg.stats.pos1, UIParent, cfg.stats.pos3, cfg.stats.pos2, cfg.stats.pos4 }
	local customColor = false
	local useShadow = true
	local showClock = flase
	local use12 = false

	local StatsFrame = CreateFrame('Frame', 'LynStats', UIParent)

	local color
	if customColor then
		color = { r = 0, g = 1, b = 0.7 }
	else
		local _, class = UnitClass("player")
		color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
	end

	local gradientColor = {
	    0, 1, 0,
	    1, 1, 0,
	    1, 0, 0
	}

	local function memFormat(number)
		if number > 1024 then
			return string.format("%.2f mb", (number / 1024))
		else
			return string.format("%.1f kb", floor(number))
		end
	end

	local function numFormat(v)
		if v > 1E10 then
			return (floor(v/1E9)).."b"
		elseif v > 1E9 then
			return (floor((v/1E9)*10)/10).."b"
		elseif v > 1E7 then
			return (floor(v/1E6)).."m"
		elseif v > 1E6 then
			return (floor((v/1E6)*10)/10).."m"
		elseif v > 1E4 then
			return (floor(v/1E3)).."k"
		elseif v > 1E3 then
			return (floor((v/1E3)*10)/10).."k"
		else
			return v
		end
	end

	local function ColorGradient(perc, ...)
	    if (perc > 1) then
	        local r, g, b = select(select('#', ...) - 2, ...) return r, g, b
	    elseif (perc < 0) then
	        local r, g, b = ... return r, g, b
	    end

	    local num = select('#', ...) / 3

	    local segment, relperc = math.modf(perc*(num-1))
	    local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	    return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
	end

	local function RGBGradient(num)
	    local r, g, b = ColorGradient(num, unpack(gradientColor))
	    return r, g, b
	end

	local function RGBToHex(r, g, b)
	    r = r <= 1 and r >= 0 and r or 0
	    g = g <= 1 and g >= 0 and g or 0
	    b = b <= 1 and b >= 0 and b or 0
	    return string.format('|cff%02x%02x%02x', r*255, g*255, b*255)
	end

	local function addonCompare(a, b)
		return a.memory > b.memory
	end

	local function clearGarbage()
		UpdateAddOnMemoryUsage()
		local before = gcinfo()
		collectgarbage()
		UpdateAddOnMemoryUsage()
		local after = gcinfo()
		print("|c0000ddffCleaned:|r "..memFormat(before-after))
	end

	StatsFrame:EnableMouse(true)
	StatsFrame:SetScript("OnMouseDown", function()
		clearGarbage()
	end)

	local function getFPS()
		return "|c00ffffff" .. floor(GetFramerate()) .. "|r FPS"
	end

	local function getLatencyWorldRaw()
		return select(4, GetNetStats())
	end

	local function getLatencyWorld()
		return "|c00ffffff" .. getLatencyWorldRaw() .. "|r MS"
	end

	local function getLatencyRaw()
		return select(3, GetNetStats())
	end

	local function getLatency()
		return "|c00ffffff" .. getLatencyRaw() .. "|r MS"
	end

	local function getMail()
		if HasNewMail() ~= false then
			return "|c00ff00ffMail!|r"
		else
			return ""
		end
	end

	local function getTime()
		if use12 == true then
			local t = date("%I:%M")
			local ampm = date("%p")
			return "|c00ffffff"..t.."|r "..strlower(ampm)
		else
			local t = date("%H:%M")
			return "|c00ffffff"..t.."|r"
		end
	end

	local function addonTooltip(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		local blizz = collectgarbage("count")
		local addons = {}
		local enry, memory
		local total = 0
		local nr = 0
		UpdateAddOnMemoryUsage()
		GameTooltip:AddLine("AddOns", color.r, color.g, color.b)
		--GameTooltip:AddLine(" ")
		for i=1, GetNumAddOns(), 1 do
			if (GetAddOnMemoryUsage(i) > 0 ) then
				memory = GetAddOnMemoryUsage(i)
				entry = {name = GetAddOnInfo(i), memory = memory}
				table.insert(addons, entry)
				total = total + memory
			end
		end
		table.sort(addons, addonCompare)
		for _, entry in pairs(addons) do
			if nr < addonList then
				GameTooltip:AddDoubleLine(entry.name, memFormat(entry.memory), 1, 1, 1, RGBGradient(entry.memory / 800))
				nr = nr+1
			end
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("Total", memFormat(total), 1, 1, 1, RGBGradient(total / (1024*10)))
		GameTooltip:AddDoubleLine("Total incl. Blizzard", memFormat(blizz), 1, 1, 1, RGBGradient(blizz / (1024*10)))
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Network", color.r, color.g, color.b)
		--GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("Home", getLatencyRaw().." ms", 1, 1, 1, RGBGradient(getLatencyRaw()/ 100))
		GameTooltip:AddDoubleLine("World", getLatencyWorldRaw().." ms", 1, 1, 1, RGBGradient(getLatencyWorldRaw()/ 100))
		GameTooltip:Show()
	end

	StatsFrame:SetScript("OnEnter", function()
		addonTooltip(StatsFrame)
	end)
	StatsFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	StatsFrame:SetPoint(unpack(position))
	StatsFrame:SetWidth(50)
	StatsFrame:SetHeight(fontSize)

	StatsFrame.text = StatsFrame:CreateFontString(nil, 'BACKGROUND')
	StatsFrame.text:SetPoint(textAlign, StatsFrame)
	StatsFrame.text:SetFont(font, fontSize, fontFlag)
	if useShadow then
		StatsFrame.text:SetShadowOffset(1, -1)
		StatsFrame.text:SetShadowColor(0, 0, 0)
	end
	StatsFrame.text:SetTextColor(color.r, color.g, color.b)

	local lastUpdate = 0

	local function update(self,elapsed)
		lastUpdate = lastUpdate + elapsed
		if lastUpdate > 1 then
			lastUpdate = 0
			if showClock == true then
				StatsFrame.text:SetText(getFPS().." "..getLatency().." "..getTime())
			else
				StatsFrame.text:SetText(getFPS().."  -  "..getLatency())
			end
			self:SetWidth(StatsFrame.text:GetStringWidth())
			self:SetHeight(StatsFrame.text:GetStringHeight())
		end
	end

	StatsFrame:SetScript("OnEvent", function(self, event)
		if(event=="PLAYER_LOGIN") then
			self:SetScript("OnUpdate", update)
		end
	end)
	StatsFrame:RegisterEvent("PLAYER_LOGIN")
end

function Misc:HoverBind()
	local bind, localmacros = CreateFrame("Frame", "ncHoverBind", UIParent), 0

	SlashCmdList.MOUSEOVERBIND = function()
		if InCombatLockdown() then print("You can't bind keys in combat.") return end
		if not bind.loaded then
			local find = string.find
			local _G = getfenv(0)

			bind:SetFrameStrata("DIALOG")
			bind:EnableMouse(true)
			bind:EnableKeyboard(true)
			bind:EnableMouseWheel(true)
			bind.texture = bind:CreateTexture()
			bind.texture:SetAllPoints(bind)
			bind.texture:SetTexture(0, 0, 0, .25)
			bind:Hide()

			local elapsed = 0
			GameTooltip:HookScript("OnUpdate", function(self, e)
				elapsed = elapsed + e
				if elapsed < .2 then return else elapsed = 0 end
				if (not self.comparing and IsModifiedClick("COMPAREITEMS")) then
					GameTooltip_ShowCompareItem(self)
					self.comparing = true
				elseif ( self.comparing and not IsModifiedClick("COMPAREITEMS")) then
					for _, frame in pairs(self.shoppingTooltips) do
						frame:Hide()
					end
					self.comparing = false
				end
			end)
			hooksecurefunc(GameTooltip, "Hide", function(self) for _, tt in pairs(self.shoppingTooltips) do tt:Hide() end end)

			bind:SetScript("OnEvent", function(self) self:Deactivate(false) end)
			bind:SetScript("OnLeave", function(self) self:HideFrame() end)
			bind:SetScript("OnKeyUp", function(self, key) self:Listener(key) end)
			bind:SetScript("OnMouseUp", function(self, key) self:Listener(key) end)
			bind:SetScript("OnMouseWheel", function(self, delta) if delta>0 then self:Listener("MOUSEWHEELUP") else self:Listener("MOUSEWHEELDOWN") end end)

			function bind:Update(b, spellmacro)
				if not self.enabled or InCombatLockdown() then return end
				self.button = b
				self.spellmacro = spellmacro

				self:ClearAllPoints()
				self:SetAllPoints(b)
				self:Show()

				ShoppingTooltip1:Hide()

				if spellmacro=="SPELL" then
					self.button.id = SpellBook_GetSpellBookSlot(self.button)
					self.button.name = GetSpellBookItemName(self.button.id, SpellBookFrame.bookType)

					GameTooltip:AddLine("Trigger")
					GameTooltip:Show()
					GameTooltip:SetScript("OnHide", function(self)
						self:SetOwner(bind, "ANCHOR_NONE")
						self:SetPoint("BOTTOM", bind, "TOP", 0, 1)
						self:AddLine(bind.button.name, 1, 1, 1)
						bind.button.bindings = {GetBindingKey(spellmacro.." "..bind.button.name)}
						if #bind.button.bindings == 0 then
							self:AddLine("No bindings set.", .6, .6, .6)
						else
							self:AddDoubleLine("Binding", "Key", .6, .6, .6, .6, .6, .6)
							for i = 1, #bind.button.bindings do
								self:AddDoubleLine(i, bind.button.bindings[i])
							end
						end
						self:Show()
						self:SetScript("OnHide", nil)
					end)
				elseif spellmacro=="MACRO" then
					self.button.id = self.button:GetID()

					if localmacros==1 then self.button.id = self.button.id + 120 end

					self.button.name = GetMacroInfo(self.button.id)

					GameTooltip:SetOwner(bind, "ANCHOR_NONE")
					GameTooltip:SetPoint("BOTTOM", bind, "TOP", 0, 1)
					GameTooltip:AddLine(bind.button.name, 1, 1, 1)

					bind.button.bindings = {GetBindingKey(spellmacro.." "..bind.button.name)}
						if #bind.button.bindings == 0 then
							GameTooltip:AddLine("No bindings set.", .6, .6, .6)
						else
							GameTooltip:AddDoubleLine("Binding", "Key", .6, .6, .6, .6, .6, .6)
							for i = 1, #bind.button.bindings do
								GameTooltip:AddDoubleLine("Binding"..i, bind.button.bindings[i], 1, 1, 1)
							end
						end
					GameTooltip:Show()
				elseif spellmacro=="STANCE" or spellmacro=="PET" then
					self.button.id = tonumber(b:GetID())
					self.button.name = b:GetName()

					if not self.button.name then return end

					if not self.button.id or self.button.id < 1 or self.button.id > (spellmacro=="STANCE" and 10 or 12) then
						self.button.bindstring = "CLICK "..self.button.name..":LeftButton"
					else
						self.button.bindstring = (spellmacro=="STANCE" and "SHAPESHIFTBUTTON" or "BONUSACTIONBUTTON")..self.button.id
					end

					GameTooltip:AddLine("Trigger")
					GameTooltip:Show()
					GameTooltip:SetScript("OnHide", function(self)
						self:SetOwner(bind, "ANCHOR_NONE")
						self:SetPoint("BOTTOM", bind, "TOP", 0, 1)
						self:AddLine(bind.button.name, 1, 1, 1)
						bind.button.bindings = {GetBindingKey(bind.button.bindstring)}
						if #bind.button.bindings == 0 then
							self:AddLine("No bindings set.", .6, .6, .6)
						else
							self:AddDoubleLine("Binding", "Key", .6, .6, .6, .6, .6, .6)
							for i = 1, #bind.button.bindings do
								self:AddDoubleLine(i, bind.button.bindings[i])
							end
						end
						self:Show()
						self:SetScript("OnHide", nil)
					end)
				else
					self.button.action = tonumber(b.action)
					self.button.name = b:GetName()

					if not self.button.name then return end

					if not self.button.action or self.button.action < 1 or self.button.action > 132 then
						self.button.bindstring = "CLICK "..self.button.name..":LeftButton"
					else
						local modact = 1+(self.button.action-1)%12
						if self.button.action < 25 or self.button.action > 72 then
							self.button.bindstring = "ACTIONBUTTON"..modact
						elseif self.button.action < 73 and self.button.action > 60 then
							self.button.bindstring = "MULTIACTIONBAR1BUTTON"..modact
						elseif self.button.action < 61 and self.button.action > 48 then
							self.button.bindstring = "MULTIACTIONBAR2BUTTON"..modact
						elseif self.button.action < 49 and self.button.action > 36 then
							self.button.bindstring = "MULTIACTIONBAR4BUTTON"..modact
						elseif self.button.action < 37 and self.button.action > 24 then
							self.button.bindstring = "MULTIACTIONBAR3BUTTON"..modact
						end
					end

					GameTooltip:AddLine("Trigger")
					GameTooltip:Show()
					GameTooltip:SetScript("OnHide", function(self)
						self:SetOwner(bind, "ANCHOR_NONE")
						self:SetPoint("BOTTOM", bind, "TOP", 0, 1)
						self:AddLine(bind.button.name, 1, 1, 1)
						bind.button.bindings = {GetBindingKey(bind.button.bindstring)}
						if #bind.button.bindings == 0 then
							self:AddLine("No bindings set.", .6, .6, .6)
						else
							self:AddDoubleLine("Binding", "Key", .6, .6, .6, .6, .6, .6)
							for i = 1, #bind.button.bindings do
								self:AddDoubleLine(i, bind.button.bindings[i])
							end
						end
						self:Show()
						self:SetScript("OnHide", nil)
					end)
				end
			end

			function bind:Listener(key)
				if key == "ESCAPE" or key == "RightButton" then
					for i = 1, #self.button.bindings do
						SetBinding(self.button.bindings[i])
					end
					print("All keybindings cleared for |cff00ff00"..self.button.name.."|r.")
					self:Update(self.button, self.spellmacro)
					if self.spellmacro~="MACRO" then GameTooltip:Hide() end
					return
				end

				if key == "LSHIFT"
				or key == "RSHIFT"
				or key == "LCTRL"
				or key == "RCTRL"
				or key == "LALT"
				or key == "RALT"
				or key == "UNKNOWN"
				or key == "LeftButton"
				or key == "MiddleButton"
				then return end


				if key == "Button4" then key = "BUTTON4" end
				if key == "Button5" then key = "BUTTON5" end

				local alt = IsAltKeyDown() and "ALT-" or ""
				local ctrl = IsControlKeyDown() and "CTRL-" or ""
				local shift = IsShiftKeyDown() and "SHIFT-" or ""

				if not self.spellmacro or self.spellmacro=="PET" or self.spellmacro=="STANCE" then
					SetBinding(alt..ctrl..shift..key, self.button.bindstring)
				else
					SetBinding(alt..ctrl..shift..key, self.spellmacro.." "..self.button.name)
				end
				print(alt..ctrl..shift..key.." |cff00ff00bound to |r"..self.button.name..".")
				self:Update(self.button, self.spellmacro)
				if self.spellmacro~="MACRO" then GameTooltip:Hide() end
			end
			function bind:HideFrame()
				self:ClearAllPoints()
				self:Hide()
				GameTooltip:Hide()
			end
			function bind:Activate()
				self.enabled = true
				self:RegisterEvent("PLAYER_REGEN_DISABLED")
			end
			function bind:Deactivate(save)
				if save then
					SaveBindings(2)
					print("All keybindings have been saved.")
				else
					LoadBindings(2)
					print("All newly set keybindings have been discarded.")
				end
				self.enabled = false
				self:HideFrame()
				self:UnregisterEvent("PLAYER_REGEN_DISABLED")
				StaticPopup_Hide("KEYBIND_MODE")
			end

			StaticPopupDialogs["KEYBIND_MODE"] = {
				text = "Hover your mouse over any actionbutton to bind it. Press the escape key or right click to clear the current actionbutton's keybinding.",
				button1 = "Save bindings",
				button2 = "Discard bindings",
				OnAccept = function() bind:Deactivate(true) end,
				OnCancel = function() bind:Deactivate(false) end,
				timeout = 0,
				whileDead = 1,
				hideOnEscape = false
			}

			-- REGISTERING
			local stance = StanceButton1:GetScript("OnClick")
			local pet = PetActionButton1:GetScript("OnClick")
	--		local button = SecureActionButton_OnClick
			local button = ActionButton1:GetScript("OnClick")

			local function register(val)
				if val.IsProtected and val.GetObjectType and val.GetScript and val:GetObjectType()=="CheckButton" and val:IsProtected() then
					local script = val:GetScript("OnClick")
					if script==button then
						val:HookScript("OnEnter", function(self) bind:Update(self) end)
					elseif script==stance then
						val:HookScript("OnEnter", function(self) bind:Update(self, "STANCE") end)
					elseif script==pet then
						val:HookScript("OnEnter", function(self) bind:Update(self, "PET") end)
					end
				end
			end

			local val = EnumerateFrames()
			while val do
				register(val)
				val = EnumerateFrames(val)
			end

			for i=1,12 do
				local sb = _G["SpellButton"..i]
				sb:HookScript("OnEnter", function(self) bind:Update(self, "SPELL") end)
			end

			local function registermacro()
				for i=1,120 do
					local mb = _G["MacroButton"..i]
					mb:HookScript("OnEnter", function(self) bind:Update(self, "MACRO") end)
				end
				MacroFrameTab1:HookScript("OnMouseUp", function() localmacros = 0 end)
				MacroFrameTab2:HookScript("OnMouseUp", function() localmacros = 1 end)
			end

			if not IsAddOnLoaded("Blizzard_MacroUI") then
				hooksecurefunc("LoadAddOn", function(addon)
					if addon=="Blizzard_MacroUI" then
						registermacro()
					end
				end)
			else
				registermacro()
			end
			bind.loaded = 1
		end
		if not bind.enabled then
			bind:Activate()
			StaticPopup_Show("KEYBIND_MODE")
		end
	end

	if (IsAddOnLoaded("HealBot")) then
		SLASH_MOUSEOVERBIND1 = "/hvb"
	else
		SLASH_MOUSEOVERBIND1 = "/hb"
	end
	--SLASH_MOUSEOVERBIND1 = "/hvb"
	SLASH_MOUSEOVERBIND2 = "/hoverbind"
end

function Misc:TooltipID()
	local hooksecurefunc, select, UnitBuff, UnitDebuff, UnitAura, UnitGUID,
        GetGlyphSocketInfo, tonumber, strfind
      = hooksecurefunc, select, UnitBuff, UnitDebuff, UnitAura, UnitGUID,
        GetGlyphSocketInfo, tonumber, strfind

  local types = {
    spell = "SpellID:",
    item  = "ItemID:",
    unit = "NPC ID:",
    quest = "QuestID:",
    talent = "TalentID:",
    achievement = "AchievementID:",
    criteria = "CriteriaID:",
    ability = "AbilityID:",
    currency = "CurrencyID:",
    artifactpower = "ArtifactPowerID:",
    enchant = "EnchantID:",
    bonus = "BonusID:",
    gem = "GemID:"
  }

  local function addLine(tooltip, id, type)
    local found = false

    -- Check if we already added to this tooltip. Happens on the talent frame
    for i = 1,15 do
      local frame = _G[tooltip:GetName() .. "TextLeft" .. i]
      local text
      if frame then text = frame:GetText() end
      if text and text == type then found = true break end
    end

    if not found then
      tooltip:AddDoubleLine(type, "|cffffffff" .. id)
      tooltip:Show()
    end
  end

  -- All types, primarily for detached tooltips
  local function onSetHyperlink(self, link)
    local type, id = string.match(link,"^(%a+):(%d+)")
    if not type or not id then return end
    if type == "spell" or type == "enchant" or type == "trade" then
      addLine(self, id, types.spell)
    elseif type == "talent" then
      addLine(self, id, types.talent)
    elseif type == "quest" then
      addLine(self, id, types.quest)
    elseif type == "achievement" then
      addLine(self, id, types.achievement)
    elseif type == "item" then
      addLine(self, id, types.item)
    elseif type == "currency" then
      addLine(self, id, types.currency)
    end
  end

  hooksecurefunc(ItemRefTooltip, "SetHyperlink", onSetHyperlink)
  hooksecurefunc(GameTooltip, "SetHyperlink", onSetHyperlink)

  -- Spells
  hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, ...)
    local id = select(11, UnitBuff(...))
    if id then addLine(self, id, types.spell) end
  end)

  hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
    local id = select(11, UnitDebuff(...))
    if id then addLine(self, id, types.spell) end
  end)

  hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
    local id = select(11, UnitAura(...))
    if id then addLine(self, id, types.spell) end
  end)

  hooksecurefunc("SetItemRef", function(link, ...)
    local id = tonumber(link:match("spell:(%d+)"))
    if id then addLine(ItemRefTooltip, id, types.spell) end
  end)

  GameTooltip:HookScript("OnTooltipSetSpell", function(self)
    local id = select(3, self:GetSpell())
    if id then addLine(self, id, types.spell) end
  end)

  -- Artifact Powers
  hooksecurefunc(GameTooltip, "SetArtifactPowerByID", function(self, powerID)
    local powerInfo = C_ArtifactUI.GetPowerInfo(powerID)
    local spellID = powerInfo.spellID
    if powerID then addLine(self, powerID, types.artifactpower) end
    if spellID then addLine(self, spellID, types.spell) end
  end)

  -- NPCs
  GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    if C_PetBattles.IsInBattle() then return end
    local unit = select(2, self:GetUnit())
    if unit then
      local guid = UnitGUID(unit) or ""
      local id = tonumber(guid:match("-(%d+)-%x+$"), 10)
      if id and guid:match("%a+") ~= "Player" then addLine(GameTooltip, id, types.unit) end
    end
  end)

  -- Items
  local function attachItemTooltip(self)
    local link = select(2, self:GetItem())
    if not link then return end

    local itemString = string.match(link, "item:([%-?%d:]+)")
    if not itemString then return end

    local enchantid = ""
    local bonusid = ""
    local gemid = ""
    local bonuses = {}
    local itemSplit = {}

    for v in string.gmatch(itemString, "(%d*:?)") do
      if v == ":" then
        itemSplit[#itemSplit + 1] = 0
      else
        itemSplit[#itemSplit + 1] = string.gsub(v, ':', '')
      end
    end

    for index = 1, tonumber(itemSplit[13]) do
      bonuses[#bonuses + 1] = itemSplit[13 + index]
    end

    local gems = {}
    for i=1, 4 do
      local _,gemLink = GetItemGem(link, i)
      if gemLink then
        local gemDetail = string.match(gemLink, "item[%-?%d:]+")
        gems[#gems + 1] = string.match(gemDetail, "item:(%d+):")
      elseif flags == 256 then
        gems[#gems + 1] = "0"
      end
    end

    local id = string.match(link, "item:(%d*)")
    if (id == "" or id == "0") and TradeSkillFrame ~= nil and TradeSkillFrame:IsVisible() and GetMouseFocus().reagentIndex then
      local selectedRecipe = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
      for i = 1, 8 do
        if GetMouseFocus().reagentIndex == i then
          id = C_TradeSkillUI.GetRecipeReagentItemLink(selectedRecipe, i):match("item:(%d*)") or nil
          break
        end
      end
    end

    if id and id ~= "" then
      addLine(self, id, types.item)
      if itemSplit[2] ~=0 then
        enchantid = itemSplit[2]
        addLine(self, enchantid, types.enchant)
      end
      if #bonuses > 0 then
        bonusid = table.concat(bonuses, '/')
        addLine(self, bonusid, types.bonus)
      end
      if #gems > 0 then
        gemid = table.concat(gems, '/')
        addLine(self, gemid, types.gem)
      end
    end
  end

  GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
  ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
  ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
  ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
  ShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
  ShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)

  -- Achievement Frame Tooltips
  local f = CreateFrame("frame")
  f:RegisterEvent("ADDON_LOADED")
  f:SetScript("OnEvent", function(_, _, what)
    if what == "Blizzard_AchievementUI" then
      for i,button in ipairs(AchievementFrameAchievementsContainer.buttons) do
        button:HookScript("OnEnter", function()
          GameTooltip:SetOwner(button, "ANCHOR_NONE")
          GameTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, 0)
          addLine(GameTooltip, button.id, types.achievement)
          GameTooltip:Show()
        end)
        button:HookScript("OnLeave", function()
          GameTooltip:Hide()
        end)

        local hooked = {}
        hooksecurefunc("AchievementButton_GetCriteria", function(index, renderOffScreen)
          local frame = _G["AchievementFrameCriteria" .. (renderOffScreen and "OffScreen" or "") .. index]
          if frame and not hooked[frame] then
            frame:HookScript("OnEnter", function(self)
              local button = self:GetParent() and self:GetParent():GetParent()
              if not button or not button.id then return end
              local criteriaid = select(10, GetAchievementCriteriaInfo(button.id, index))
              if criteriaid then
                GameTooltip:SetOwner(button:GetParent(), "ANCHOR_NONE")
                GameTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, 0)
                addLine(GameTooltip, button.id, types.achievement)
                addLine(GameTooltip, criteriaid, types.criteria)
                GameTooltip:Show()
              end
            end)
            frame:HookScript("OnLeave", function()
              GameTooltip:Hide()
            end)
            hooked[frame] = true
          end
        end)
      end
    end
  end)

  -- Pet battle buttons
  hooksecurefunc("PetBattleAbilityButton_OnEnter", function(self)
    local petIndex = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY)
    if ( self:GetEffectiveAlpha() > 0 ) then
      local id = select(1, C_PetBattles.GetAbilityInfo(LE_BATTLE_PET_ALLY, petIndex, self:GetID()))
      if id then
        local oldText = PetBattlePrimaryAbilityTooltip.Description:GetText(id)
        PetBattlePrimaryAbilityTooltip.Description:SetText(oldText .. "\r\r" .. types.ability .. "|cffffffff " .. id .. "|r")
      end
    end
  end)

  -- Pet battle auras
  hooksecurefunc("PetBattleAura_OnEnter", function(self)
    local parent = self:GetParent()
    local id = select(1, C_PetBattles.GetAuraInfo(parent.petOwner, parent.petIndex, self.auraIndex))
    if id then
      local oldText = PetBattlePrimaryAbilityTooltip.Description:GetText(id)
      PetBattlePrimaryAbilityTooltip.Description:SetText(oldText .. "\r\r" .. types.ability .. "|cffffffff " .. id .. "|r")
    end
  end)

  -- Currencies
  hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
    local id = tonumber(string.match(GetCurrencyListLink(index),"currency:(%d+)"))
    if id then addLine(self, id, types.currency) end
  end)

  hooksecurefunc(GameTooltip, "SetCurrencyByID", function(self, id)
     if id then addLine(self, id, types.currency) end
  end)

  hooksecurefunc(GameTooltip, "SetCurrencyTokenByID", function(self, id)
     if id then addLine(self, id, types.currency) end
  end)

  -- Quests
  do
    local function questhook(self)
      if self.questID then addLine(GameTooltip, self.questID, types.quest) end
    end
    local titlebuttonshooked = {}
    hooksecurefunc("QuestLogQuests_GetTitleButton", function(index)
      local titles = QuestMapFrame.QuestsFrame.Contents.Titles;
      if titles[index] and not titlebuttonshooked[index] then
        titles[index]:HookScript("OnEnter", questhook)
        titlebuttonshooked[index] = true
      end
    end)
  end

  hooksecurefunc("TaskPOI_OnEnter", function(self)
    if self and self.questID then addLine(WorldMapTooltip, self.questID, types.quest) end
  end)
end

function Misc:SafeQueue()
	local SafeQueue = CreateFrame("Frame")
	local queueTime
	local queue = 0
	local remaining = 0
	SafeQueueDB = SafeQueueDB or { announce = "self" }

	PVPReadyDialog.leaveButton:Hide()
	PVPReadyDialog.leaveButton.Show = function() end
	PVPReadyDialog.enterButton:ClearAllPoints()
	PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)
	PVPReadyDialog.label:SetPoint("TOP", 0, -22)

	local function Print(msg)
		DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99SafeQueue|r: " .. msg)
	end

	local function PrintTime()
		local announce = SafeQueueDB.announce
		if announce == "off" then return end
		local secs, str, mins = floor(GetTime() - queueTime), "Queue popped "
		if secs < 1 then
			str = str .. "instantly!"
		else
			str = str .. "after "
			if secs >= 60 then
				mins = floor(secs/60)
				str = str .. mins .. "m "
				secs = secs%60
			end
			if secs%60 ~= 0 then
				str = str .. secs .. "s"
			end
		end
		if announce == "self" or not IsInGroup() then
			Print(str)
		else
			local group = IsInRaid() and "RAID" or "PARTY"
			SendChatMessage(str, group)
		end
	end

	SafeQueue:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	SafeQueue:SetScript("OnEvent", function()
		local queued
		for i=1, GetMaxBattlefieldID() do
			local status = GetBattlefieldStatus(i)
			if status == "queued" then
				queued = true
				if not queueTime then queueTime = GetTime() end
			elseif status == "confirm" then
				if queueTime then
					PrintTime()
					queueTime = nil
					remaining = 0
					queue = i
				end
			end
			break
		end
		if not queued and queueTime then queueTime = nil end
	end)

	SafeQueue:SetScript("OnUpdate", function(self)
		if PVPReadyDialog_Showing(queue) then
			local secs = GetBattlefieldPortExpiration(queue)
			if secs and secs > 0 and remaining ~= secs then
				remaining = secs
				local color = secs > 20 and "f20ff20" or secs > 10 and "fffff00" or "fff0000"
				PVPReadyDialog.label:SetText("Expires in |cf"..color.. SecondsToTime(secs) .. "|r")
			end
		end
	end)
end

-- Set Max Equipement Sets to 100.
	
setglobal("MAX_EQUIPMENT_SETS_PER_PLAYER",100)