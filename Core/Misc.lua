local _, JokUI = ...
local Misc = JokUI:RegisterModule("Miscellaneous")

local features = {}

local font = STANDARD_TEXT_FONT

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------

local misc_defaults = {
    profile = {
    	PowerBarAlt = {
    		point = "BOTTOM",
    		x = -240,
    		y = 197, 
    	},
    	ExtraActionButton = {
    		point = "BOTTOM",
    		x = 0,
    		y = 205, 
    	},		
    }
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
	JokUI.Config:Register("Miscellaneous", misc_config, 14)

	self:RegisterEvent("ADDON_LOADED")

	self:AutoRep()
	self:SGrid()
	self:TooltipID()
	self:ShowStats()
	self:Specialization()
	self:EquipmentSets()
	self:Warmode()
	self:Dampening()
	self:HoverBind()
	self:SafeQueue()
	self:Talents()
	self:AFK()
	self:ItemLevel()
	self:Surrender()
	self:TeleportCloak()
	self:Quests()
	self:SkipCinematic()
	self:ExtraActionButton()
	self:PowerBarAlt()

	-- Set Max Equipement Sets to 100.	
	setglobal("MAX_EQUIPMENT_SETS_PER_PLAYER",100)

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
				LossOfControlFrame:ClearAllPoints() 
				LossOfControlFrame:SetPoint("CENTER",UIParent,"CENTER",0,0)
				select(1,LossOfControlFrame:GetRegions()):SetAlpha(0)
				select(2,LossOfControlFrame:GetRegions()):SetAlpha(0) 
				select(3,LossOfControlFrame:GetRegions()):SetAlpha(0)
			end
		end)
end

do
	Misc:RegisterFeature("FastLooting",
		"Fast Auto-Looting",
		"Increase looting speed when you have autoloot enabled.",
		true,
		true,
		function(state)
			if state then
				----------------------------------------------------------------------
				--	Faster looting
				----------------------------------------------------------------------

				-- Time delay
				local tDelay = 0

				-- Fast loot function
				local function FastLoot()
					if GetTime() - tDelay >= 0.2 then
						tDelay = GetTime()
							if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
							for i = GetNumLootItems(), 1, -1 do
								LootSlot(i)
							end
							tDelay = GetTime()
						end
					end
				end

				-- Event frame
				local faster = CreateFrame("Frame")
				faster:RegisterEvent("LOOT_READY")
				faster:SetScript("OnEvent", FastLoot)
			end
		end)
end

function Misc:AutoRep()

	-- AUTO SELL

	-- Create sell junk banner
	local StartMsg = CreateFrame("FRAME", nil, MerchantFrame)
	StartMsg:ClearAllPoints()
	StartMsg:SetPoint("BOTTOMLEFT", 4, 4)
	StartMsg:SetSize(160, 22)
	StartMsg:SetToplevel(true)
	StartMsg:Hide()

	StartMsg.s = StartMsg:CreateTexture(nil, "BACKGROUND")
	StartMsg.s:SetAllPoints()
	StartMsg.s:SetColorTexture(0.1, 0.1, 0.1, 1.0)

	StartMsg.f = StartMsg:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge") 
	StartMsg.f:SetAllPoints();
	StartMsg.f:SetText("SELLING JUNK")

	-- Declarations
	local IterationCount, totalPrice = 500, 0
	local SellJunkFrame = CreateFrame("FRAME")
	local SellJunkTicker, mBagID, mBagSlot

	-- Function to stop selling
	local function StopSelling()
		if SellJunkTicker then SellJunkTicker:Cancel() end
		StartMsg:Hide()
		SellJunkFrame:UnregisterEvent("ITEM_LOCKED")
		SellJunkFrame:UnregisterEvent("ITEM_UNLOCKED")
	end

	-- Vendor function
	local function SellJunkFunc()

		-- Variables
		local SoldCount, Rarity, ItemPrice = 0, 0, 0
		local CurrentItemLink, void

		-- Traverse bags and sell grey items
		for BagID = 0, 4 do
			for BagSlot = 1, GetContainerNumSlots(BagID) do
				CurrentItemLink = GetContainerItemLink(BagID, BagSlot)
				if CurrentItemLink then
					void, void, Rarity, void, void, void, void, void, void, void, ItemPrice = GetItemInfo(CurrentItemLink)
					local void, itemCount = GetContainerItemInfo(BagID, BagSlot)
					if Rarity == 0 and ItemPrice ~= 0 then
						SoldCount = SoldCount + 1
						if MerchantFrame:IsShown() then
							-- If merchant frame is open, vendor the item
							UseContainerItem(BagID, BagSlot)
							-- Perform actions on first iteration
							if SellJunkTicker._remainingIterations == IterationCount then
								-- Calculate total price
								totalPrice = totalPrice + (ItemPrice * itemCount)
								-- Store first sold bag slot for analysis
								if SoldCount == 1 then
									mBagID, mBagSlot = BagID, BagSlot
								end
							end
						else
							-- If merchant frame is not open, stop selling
							StopSelling()
							return
						end
					end
				end
			end
		end

		-- Stop selling if no items were sold for this iteration or iteration limit was reached
		if SoldCount == 0 or SellJunkTicker and SellJunkTicker._remainingIterations == 1 then 
			StopSelling() 
			if totalPrice > 0 then 
				print("Sold junk for".. " " .. GetCoinText(totalPrice) .. ".")
			end
		end

	end

	SellJunkFrame:RegisterEvent("MERCHANT_SHOW");
	SellJunkFrame:RegisterEvent("MERCHANT_CLOSED");

	-- Event handler
	SellJunkFrame:SetScript("OnEvent", function(self, event)
		if event == "MERCHANT_SHOW" then
			-- Reset variables
			totalPrice, mBagID, mBagSlot = 0, -1, -1
			-- Do nothing if shift key is held down
			if IsShiftKeyDown() then return end
			-- Cancel existing ticker if present
			if SellJunkTicker then SellJunkTicker:Cancel() end
			-- Sell grey items using ticker (ends when all grey items are sold or iteration count reached)
			SellJunkTicker = C_Timer.NewTicker(0.2, SellJunkFunc, IterationCount)
			SellJunkFrame:RegisterEvent("ITEM_LOCKED")
			SellJunkFrame:RegisterEvent("ITEM_UNLOCKED")
		elseif event == "ITEM_LOCKED" then
			StartMsg:Show()
			SellJunkFrame:UnregisterEvent("ITEM_LOCKED")
		elseif event == "ITEM_UNLOCKED" then
			SellJunkFrame:UnregisterEvent("ITEM_UNLOCKED")
			-- Check whether vendor refuses to buy items
			if mBagID and mBagSlot and mBagID ~= -1 and mBagSlot ~= -1 then
				local texture, count, locked = GetContainerItemInfo(mBagID, mBagSlot)
				if count and not locked then
					-- Item has been unlocked but still not sold so stop selling
					StopSelling()
				end
			end
		elseif event == "MERCHANT_CLOSED" then
			-- If merchant frame is closed, stop selling
			StopSelling()
		end
	end)

	-- AUTO REPAIR

	local function AutoRepair()
		if(CanMerchantRepair()) then
			local cost, CanRepair = GetRepairAllCost()
			if CanRepair then -- If merchant is offering repair
				if IsInGuild() then
					-- Guilded character
					if CanGuildBankRepair() then
						RepairAllItems(1)
						RepairAllItems()
						print(format("|cfff07100Repair cost covered by G-Bank: %.1fg|r", cost * 0.0001))
					else
						RepairAllItems()
					end
				else
					RepairAllItems()
					print(format("|cffead000Repair cost: %.1fg|r", cost * 0.0001))
				end
			end
		end
	end

	local AutoRep = CreateFrame("Frame")
	AutoRep:RegisterEvent("MERCHANT_SHOW")
	AutoRep:SetScript("OnEvent", AutoRepair)
end

function Misc:SGrid()
	
	local frame
	local w
	local h

	function SGrid(msg)
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
				w = 64
				h = 36
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

	SLASH_SGRIDA1 = "/sgrid"
	SlashCmdList["SGRIDA"] = function(msg, editbox)
		SGrid(msg)	
	end
end

function Misc:TooltipID()
	local hooksecurefunc, select, UnitBuff, UnitDebuff, UnitAura, UnitGUID,
      GetGlyphSocketInfo, tonumber, strfind
    = hooksecurefunc, select, UnitBuff, UnitDebuff, UnitAura, UnitGUID,
      GetGlyphSocketInfo, tonumber, strfind

	local kinds = {
	  spell = "SpellID",
	  item = "ItemID",
	  unit = "NPCID",
	  quest = "QuestID",
	  talent = "TalentID",
	  achievement = "AchievementID",
	  criteria = "CriteriaID",
	  ability = "AbilityID",
	  currency = "CurrencyID",
	  artifactpower = "ArtifactPowerID",
	  enchant = "EnchantID",
	  bonus = "BonusID",
	  gem = "GemID",
	  mount = "MountID",
	  companion = "CompanionID",
	  macro = "MacroID",
	  equipmentset = "EquipmentSetID",
	  visual = "VisualID",
	  source = "SourceID",
	}

	local function contains(table, element)
	  for _, value in pairs(table) do
	    if value == element then return true end
	  end
	  return false
	end

	local function addLine(tooltip, id, kind)
	  if not id or id == "" then return end
	  if type(id) == "table" and #id == 1 then id = id[1] end

	  -- Check if we already added to this tooltip. Happens on the talent frame
	  local frame, text
	  for i = 1,15 do
	    frame = _G[tooltip:GetName() .. "TextLeft" .. i]
	    if frame then text = frame:GetText() end
	    if text and string.find(text, kind .. ":") then return end
	  end

	  local left, right
	  if type(id) == "table" then
	    left = NORMAL_FONT_COLOR_CODE .. kind .. "s:" .. FONT_COLOR_CODE_CLOSE
	    right = HIGHLIGHT_FONT_COLOR_CODE .. table.concat(id, ", ") .. FONT_COLOR_CODE_CLOSE
	  else
	    left = NORMAL_FONT_COLOR_CODE .. kind .. ":" .. FONT_COLOR_CODE_CLOSE
	    right = HIGHLIGHT_FONT_COLOR_CODE .. id .. FONT_COLOR_CODE_CLOSE
	  end

	  tooltip:AddDoubleLine(left, right)
	  tooltip:Show()
	end

	local function addLineByKind(self, id, kind)
	  if not kind or not id then return end
	  if kind == "spell" or kind == "enchant" or kind == "trade" then
	    addLine(self, id, kinds.spell)
	  elseif kind == "talent" then
	    addLine(self, id, kinds.talent)
	  elseif kind == "quest" then
	    addLine(self, id, kinds.quest)
	  elseif kind == "achievement" then
	    addLine(self, id, kinds.achievement)
	  elseif kind == "item" then
	    addLine(self, id, kinds.item)
	  elseif kind == "currency" then
	    addLine(self, id, kinds.currency)
	  elseif kind == "summonmount" then
	    addLine(self, id, kinds.mount)
	  elseif kind == "companion" then
	    addLine(self, id, kinds.companion)
	  elseif kind == "macro" then
	    addLine(self, id, kinds.macro)
	  elseif kind == "equipmentset" then
	    addLine(self, id, kinds.equipmentset)
	  elseif kind == "visual" then
	    addLine(self, id, kinds.visual)
	  end
	end

	-- All kinds
	local function onSetHyperlink(self, link)
	  local kind, id = string.match(link,"^(%a+):(%d+)")
	  addLineByKind(self, kind, id)
	end

	hooksecurefunc(GameTooltip, "SetAction", function(self, slot)
	  local kind, id = GetActionInfo(slot)
	  addLineByKind(self, id, kind)
	end)

	hooksecurefunc(ItemRefTooltip, "SetHyperlink", onSetHyperlink)
	hooksecurefunc(GameTooltip, "SetHyperlink", onSetHyperlink)

	-- Spells
	hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, ...)
	  local id = select(10, UnitBuff(...))
	  addLine(self, id, kinds.spell)
	end)

	hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self, ...)
	  local id = select(10, UnitDebuff(...))
	  addLine(self, id, kinds.spell)
	end)

	hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
	  local id = select(10, UnitAura(...))
	  addLine(self, id, kinds.spell)
	end)

	hooksecurefunc(GameTooltip, "SetSpellByID", function(self, id)
	  addLineByKind(self, id, kinds.spell)
	end)

	hooksecurefunc("SetItemRef", function(link, ...)
	  local id = tonumber(link:match("spell:(%d+)"))
	  addLine(ItemRefTooltip, id, kinds.spell)
	end)

	GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	  local id = select(3, self:GetSpell())
	  addLine(self, id, kinds.spell)
	end)

	hooksecurefunc("SpellButton_OnEnter", function(self)
	  local slot = SpellBook_GetSpellBookSlot(self)
	  local spellID = select(2, GetSpellBookItemInfo(slot, SpellBookFrame.bookType))
	  addLine(GameTooltip, spellID, kinds.spell)
	end)

	hooksecurefunc(GameTooltip, "SetRecipeResultItem", function(self, id)
	  addLine(self, id, kinds.spell)
	end)

	hooksecurefunc(GameTooltip, "SetRecipeRankInfo", function(self, id)
	  addLine(self, id, kinds.spell)
	end)

	-- Artifact Powers
	hooksecurefunc(GameTooltip, "SetArtifactPowerByID", function(self, powerID)
	  local powerInfo = C_ArtifactUI.GetPowerInfo(powerID)
	  addLine(self, powerID, kinds.artifactpower)
	  addLine(self, powerInfo.spellID, kinds.spell)
	end)

	-- Talents
	hooksecurefunc(GameTooltip, "SetTalent", function(self, id)
	  addLine(self, id, kinds.talent)
	end)
	hooksecurefunc(GameTooltip, "SetPvpTalent", function(self, id)
	  addLine(self, id, kinds.talent)
	end)

	-- NPCs
	GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	  if C_PetBattles.IsInBattle() then return end
	  local unit = select(2, self:GetUnit())
	  if unit then
	    local guid = UnitGUID(unit) or ""
	    local id = tonumber(guid:match("-(%d+)-%x+$"), 10)
	    if id and guid:match("%a+") ~= "Player" then addLine(GameTooltip, id, kinds.unit) end
	  end
	end)

	-- Items
	hooksecurefunc(GameTooltip, "SetToyByItemID", function(self, id)
	  addLine(self, id, kinds.item)
	end)

	hooksecurefunc(GameTooltip, "SetRecipeReagentItem", function(self, id)
	  addLine(self, id, kinds.item)
	end)

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
	      itemSplit[#itemSplit + 1] = string.gsub(v, ":", "")
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

	  if id then
	    addLine(self, id, kinds.item)
	    if itemSplit[2] ~= 0 then
	      enchantid = itemSplit[2]
	      addLine(self, enchantid, kinds.enchant)
	    end
	    if #bonuses ~= 0 then addLine(self, bonuses, kinds.bonus) end
	    if #gems ~= 0 then addLine(self, gems, kinds.gem) end
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
	        addLine(GameTooltip, button.id, kinds.achievement)
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
	              addLine(GameTooltip, button.id, kinds.achievement)
	              addLine(GameTooltip, criteriaid, kinds.criteria)
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
	  elseif what == "Blizzard_Collections" then
	    hooksecurefunc("WardrobeCollectionFrame_SetAppearanceTooltip", function(self, sources)
	      local visualIDs = {}
	      local sourceIDs = {}
	      local itemIDs = {}

	      for i = 1, #sources do
	        if sources[i].visualID and not contains(visualIDs, sources[i].visualID) then table.insert(visualIDs, sources[i].visualID) end
	        if sources[i].sourceID and not contains(visualIDs, sources[i].sourceID) then table.insert(sourceIDs, sources[i].sourceID) end
	        if sources[i].itemID and not contains(visualIDs, sources[i].itemID) then table.insert(itemIDs, sources[i].itemID) end
	      end

	      if #visualIDs ~= 0 then addLine(GameTooltip, visualIDs, kinds.visual) end
	      if #sourceIDs ~= 0 then addLine(GameTooltip, sourceIDs, kinds.source) end
	      if #itemIDs ~= 0 then addLine(GameTooltip, itemIDs, kinds.item) end
	    end)
	  end
	end)

	-- Pet battle buttons
	hooksecurefunc("PetBattleAbilityButton_OnEnter", function(self)
	  local petIndex = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY)
	  if self:GetEffectiveAlpha() > 0 then
	    local id = select(1, C_PetBattles.GetAbilityInfo(LE_BATTLE_PET_ALLY, petIndex, self:GetID()))
	    if id then
	      local oldText = PetBattlePrimaryAbilityTooltip.Description:GetText(id)
	      PetBattlePrimaryAbilityTooltip.Description:SetText(oldText .. "\r\r" .. kinds.ability .. "|cffffffff " .. id .. "|r")
	    end
	  end
	end)

	-- Pet battle auras
	hooksecurefunc("PetBattleAura_OnEnter", function(self)
	  local parent = self:GetParent()
	  local id = select(1, C_PetBattles.GetAuraInfo(parent.petOwner, parent.petIndex, self.auraIndex))
	  if id then
	    local oldText = PetBattlePrimaryAbilityTooltip.Description:GetText(id)
	    PetBattlePrimaryAbilityTooltip.Description:SetText(oldText .. "\r\r" .. kinds.ability .. "|cffffffff " .. id .. "|r")
	  end
	end)

	-- Currencies
	hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
	  local id = tonumber(string.match(GetCurrencyListLink(index),"currency:(%d+)"))
	  addLine(self, id, kinds.currency)
	end)

	hooksecurefunc(GameTooltip, "SetCurrencyByID", function(self, id)
	   addLine(self, id, kinds.currency)
	end)

	hooksecurefunc(GameTooltip, "SetCurrencyTokenByID", function(self, id)
	   addLine(self, id, kinds.currency)
	end)

	-- Quests
	hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
	  local id = select(8, GetQuestLogTitle(self.questLogIndex))
	  addLine(GameTooltip, id, kinds.quest)
	end)

	hooksecurefunc("TaskPOI_OnEnter", function(self)
	  if self and self.questID then addLine(WorldMapTooltip, self.questID, kinds.quest) end
	end)
end

function Misc:Talents()

	local TalentButton = CreateFrame('Frame', 'TalentButton', UIParent)
	TalentButton:RegisterEvent('ADDON_LOADED')
	TalentButton:SetScript('OnEvent', function(self, event, ...)
		self[event](self, ...)
	end)

	function TalentButton:UNIT_AURA()
		if(self:IsShown()) then
			for _, Button in next, self.Items do
				local itemName = Button.itemName
				if(itemName) then
					for i = 1, 40 do
		    			exists, _, _, _, duration, expiration = UnitAura("player", i, "HELPFUL")
		    			if exists == itemName then break end		    			
					end
					if(exists) then
						if(expiration > 0) then
							Button.Cooldown:SetCooldown(expiration - duration, duration)
						end
					else
						Button.Cooldown:SetCooldown(0, 0)
					end
				end
			end
		end
	end

	function TalentButton:BAG_UPDATE_DELAYED()
		self:UpdateItems()
	end

	function TalentButton.OnShow()
		TalentButton:RegisterUnitEvent('UNIT_AURA', 'player')
		TalentButton:RegisterEvent('BAG_UPDATE_DELAYED')
		TalentButton:UpdateItems()
	end

	function TalentButton.OnHide()
		TalentButton:UnregisterEvent('UNIT_AURA')
		TalentButton:UnregisterEvent('BAG_UPDATE_DELAYED')
	end

	function TalentButton:CreateItemButtons()
		self.Items = {}

		local OnEnter = function(self)
			if(self.itemID) then
				GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
				GameTooltip:SetItemByID(self.itemID)
				GameTooltip:Show()
			end
		end

		local OnEvent = function(self, event)
			if(event == 'PLAYER_REGEN_ENABLED') then
				self:UnregisterEvent(event)
				self:SetAttribute('item', 'item:' .. self.itemID)
			else
				local itemName = GetItemInfo(self.itemID)
				if(itemName) then
					self.itemName = itemName
					self:UnregisterEvent(event)

					TalentButton:UNIT_AURA()
				end
			end
		end

		local items = {
			{
				143780, -- Tome of the Tranquil Mind (beta)
			},
			{
				153147, -- Tome of the Tranquil Mind (beta)
			}
		}

		for index, items in next, items do
			local Button = CreateFrame('Button', '$parentItemButton' .. index, self, 'SecureActionButtonTemplate, ActionBarButtonSpellActivationAlert')
			Button:SetPoint('RIGHT', PlayerTalentFrameTalentsPvpTalentButton, -132 - (40 * (index - 1)), 0)
			Button:SetSize(34, 34)
			Button:SetAttribute('type', 'item')
			Button:SetScript('OnEnter', OnEnter)
			Button:SetScript('OnEvent', OnEvent)
			Button:SetScript('OnLeave', GameTooltip_Hide)
			Button.items = items

			local Icon = Button:CreateTexture('$parentIcon', 'BACKGROUND')
			Icon:SetAllPoints()
			Icon:SetTexture(134915)
			Icon:SetTexCoord(4/64, 60/64, 4/64, 60/64)

			local Normal = Button:CreateTexture('$parentNormalTexture')
			Normal:SetPoint('CENTER')
			Normal:SetSize(60, 60)
			Normal:SetTexture([[Interface\Buttons\UI-Quickslot2]])

			Button:SetNormalTexture(Normal)
			Button:SetPushedTexture([[Interface\Buttons\UI-Quickslot-Depress]])
			Button:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]])

			local Count = Button:CreateFontString('$parentCount', 'OVERLAY')
			Count:SetPoint('BOTTOMLEFT', 1, 1)
			Count:SetFont(font, 12, 'OUTLINE')
			Button.Count = Count

			local Cooldown = CreateFrame('Cooldown', '$parentCooldown', Button, 'CooldownFrameTemplate')
			Cooldown:SetAllPoints()
			Button.Cooldown = Cooldown

			table.insert(self.Items, Button)
		end
	end

	function TalentButton:GetAvailableItemInfo(index)
		for _, itemID in next, self.Items[index].items do
			local itemCount = GetItemCount(itemID)
			if(itemCount > 0) then
				return itemID, itemCount
			end
		end

		return self.Items[index].items[1], 0
	end

	function TalentButton:UpdateItems()
		for index, Button in next, self.Items do
			local itemID, itemCount = self:GetAvailableItemInfo(index)
			if(Button.itemID ~= itemID) then
				Button.itemID = itemID

				local itemName = GetItemInfo(itemID)
				if(not itemName) then
					Button.itemName = nil
					Button:RegisterEvent('GET_ITEM_INFO_RECEIVED')
				else
					Button.itemName = itemName
				end

				if(InCombatLockdown()) then
					Button:RegisterEvent('PLAYER_REGEN_ENABLED')
				else
					Button:SetAttribute('item', 'item:' .. itemID)
				end
			end

			Button.Count:SetText(itemCount)
		end

		self:UNIT_AURA()
	end

	function TalentButton:ADDON_LOADED(addon)
		if(addon == 'Blizzard_TalentUI') then
			self:SetParent(PlayerTalentFrameTalents)

			PlayerTalentFrame:HookScript('OnShow', self.OnShow)
			PlayerTalentFrame:HookScript('OnHide', self.OnHide)

			PlayerTalentFrameTalentsTutorialButton:Hide()
			PlayerTalentFrameTalentsTutorialButton.Show = function() end
			PlayerTalentFrameTalents.unspentText:ClearAllPoints()
			PlayerTalentFrameTalents.unspentText:SetPoint('TOP', 0, 24)

			self:CreateItemButtons()

			self:UnregisterEvent('ADDON_LOADED')
			self:OnShow()
		end
	end
end

function Misc:ShowStats()

	local addonList = 20
	local fontSize = 14
	local fontFlag = 'THINOUTLINE'
	local textAlign = 'CENTER'
	local position = { "TOPLEFT", UIParent, "TOPLEFT", 10, -5 }
	local customColor = false
	local useShadow = true
	local showClock = flase
	local use12 = false

	local StatsFrame = CreateFrame('Frame', 'JokStats', UIParent)

	local _, class = UnitClass("player")
	local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]

	local gradientColor = {
	    0, 1, 0,
	    1, 1, 0,
	    1, 0, 0
	}

	function memFormat(number)
		if number > 1024 then
			return string.format("%.2f mb", (number / 1024))
		else
			return string.format("%.1f kb", floor(number))
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

	local function getLatencyRaw()
		return select(3, GetNetStats())
	end

	local function getLatency()
		return "|c00ffffff" .. getLatencyRaw() .. "|r MS"
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

function Misc:Specialization()
	local menuList = {
		{ text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
		{ notCheckable = true, func = function() SetLootSpecialization(0) end },
		{ notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true }
	}

	local specList = {
		{ text = SPECIALIZATION, isTitle = true, notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true }
	}

	local menuFrame = CreateFrame("Frame", "LootSpecializationDatatextClickMenu", SpecFrame, "UIDropDownMenuTemplate")
	local format, join = string.format, string.join
	local lastPanel, active
	local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

	local SpecFrame = CreateFrame('Frame', 'Spec', UIParent)
	SpecFrame:SetPoint("TOPLEFT", JokStats, "TOPRIGHT", 25, -1)
	SpecFrame:SetWidth(140)
	SpecFrame:SetHeight(13)
	SpecFrame:EnableMouse(true)

	SpecFrame.text = SpecFrame:CreateFontString(nil, 'BACKGROUND')
	SpecFrame.text:SetPoint("CENTER", SpecFrame)
	SpecFrame.text:SetFont(font, 13, "OUTLINE")
	SpecFrame.text:SetShadowOffset(1, -1)
	SpecFrame.text:SetShadowColor(0, 0, 0)

	local function update(self)		
		local specIndex = GetSpecialization();
		if not specIndex then
			SpecFrame.text:SetText('N/A')
			return
		end

		local talent, loot = '', 'N/A'
		local i = GetSpecialization(false, false, active)
		if i then
			i = select(4, GetSpecializationInfo(i))
			if(i) then
				talent = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', i)
			end
		end

		local specialization = GetLootSpecialization()
		if specialization == 0 then
			local specIndex = GetSpecialization();

			if specIndex then
				local _, _, _, texture = GetSpecializationInfo(specIndex);
				if texture then
					loot = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', texture)
				end
			end
		else
			local _, _, _, texture = GetSpecializationInfoByID(specialization);
			if texture then
				loot = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', texture)
			end
		end

		SpecFrame.text:SetFormattedText('%s: %s %s: %s', "|c"..color.."SPEC ", talent," - ".. " LOOT ", loot)		
	end

	SpecFrame:SetScript("OnEvent", function(self, event)
		if (event=="PLAYER_LOOT_SPEC_UPDATED") or (event=="PLAYER_ENTERING_WORLD") or (event=="PLAYER_TALENT_UPDATE") then
			update()
		end
	end)

	SpecFrame:SetScript("OnMouseDown", function(self, button)
		local specIndex = GetSpecialization();
		if not specIndex then return end

		if button == "LeftButton" then
			GameTooltip:Hide()
			if IsShiftKeyDown() then
				ToggleTalentFrame(2)
			else
				for index = 1, 4 do
					local id, name, _, texture = GetSpecializationInfo(index);
					if ( id ) then
						specList[index + 1].text = format('|T%s:14:14:0:0:64:64:4:60:4:60|t  %s', texture, name)
						specList[index + 1].func = function() SetSpecialization(index) end
					else
						specList[index + 1] = nil
					end
				end
				EasyMenu(specList, menuFrame, SpecFrame, -4, -7, "MENU", 2)
				DropDownList1:SetScale(0.9)
			end
		elseif button == "RightButton" then

			GameTooltip:Hide()
			for index = 1, 4 do
				local id, name, _, texture = GetSpecializationInfo(index);
				if ( id ) then
					menuList[index + 2].text = format('|T%s:14:14:0:0:64:64:4:60:4:60|t  %s', texture, name)
					menuList[index + 2].func = function() SetLootSpecialization(id) end
				else
					menuList[index + 2] = nil
				end
			end

			EasyMenu(menuList, menuFrame, SpecFrame, -4, -7, "MENU", 2)
			DropDownList1:SetScale(0.9)
		end	
	end)
	
	local function addonTooltip(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")

		local specialization = GetLootSpecialization()
		if specialization == 0 then
			local specIndex = GetSpecialization();

			if specIndex then
				local _, name = GetSpecializationInfo(specIndex);
				GameTooltip:AddLine(format('|cffFFFFFF%s:|r %s', SELECT_LOOT_SPECIALIZATION, format(LOOT_SPECIALIZATION_DEFAULT, name)))
			end
		else
			local specID, name = GetSpecializationInfoByID(specialization);
			if specID then
				GameTooltip:AddLine(format('|cffFFFFFF%s:|r %s', SELECT_LOOT_SPECIALIZATION, name))
			end
		end

		GameTooltip:AddLine(' ')
		GameTooltip:AddLine("|cffFFFFFFLeft Click:|r Change Talent Specialization")
		GameTooltip:AddLine("|cffFFFFFFRight Click:|r Change Loot Specialization")
		GameTooltip:AddLine("|cffFFFFFFMAJ + Left Click:|r Show Talent Panel")

		GameTooltip:Show()
	end

	SpecFrame:SetScript("OnEnter", function()
		addonTooltip(SpecFrame)
	end)
	SpecFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	SpecFrame:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
	SpecFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	SpecFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Misc:EquipmentSets()
	local menuList = {
		{ text = "Equipment Sets\n\n", isTitle = true, notCheckable = true, justifyH = "CENTER"  },
		{ notCheckable = true, func = function() C_EquipmentSet.UseEquipmentSet(0) end },
		{ notCheckable = true, minWidth = 100},
		{ notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true },
		{ notCheckable = true }
	}

	local menuFrame = CreateFrame("Frame", "SetManagerDatatextClickMenu", SetFrame, "UIDropDownMenuTemplate")
	local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

	local SetFrame = CreateFrame('Frame', "SetFrame", UIParent)
	SetFrame:SetPoint("TOPLEFT", Spec, "TOPRIGHT", 28, 0)
	SetFrame:SetWidth(140)
	SetFrame:SetHeight(14)
	SetFrame:EnableMouse(true)

	SetFrame.text = SetFrame:CreateFontString(nil, 'BACKGROUND')
	SetFrame.text:SetPoint("CENTER", SetFrame)
	SetFrame.text:SetFont(font, 13, "OUTLINE")
	SetFrame.text:SetShadowOffset(1, -1)
	SetFrame.text:SetShadowColor(0, 0, 0)

	local function update(self)		
		local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs()
		for i = 1, C_EquipmentSet.GetNumEquipmentSets() do
			local name, icon, _, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(equipmentSetIDs[i]);
			if isEquipped then
				equippedIcon = '|T'..icon..':21:21:0:0:64:64:4:60:4:60|t'
				equippedName = name
			end
		end	
		if equippedName then
			SetFrame.text:SetFormattedText('%s %s %s', "|c"..color.."SET :|r", equippedIcon, "|r|cfff4c300"..equippedName)
			SetFrame:SetWidth(SetFrame.text:GetStringWidth())
		else
			SetFrame.text:SetFormattedText('%s', "|c"..color.."SET : |r|cfff4c300 N/A")
			SetFrame:SetWidth(SetFrame.text:GetStringWidth())		
		end
	end

	SetFrame:SetScript("OnMouseDown", function(self, button)

		if button == "LeftButton" then
			update(self)
			GameTooltip:Hide()
			if IsShiftKeyDown() then
				if PaperDollFrame:IsShown() then 
					ToggleCharacter("PaperDollFrame")
					PaperDollSidebarTab3:Click() 
				end
			else
				for i = 1, C_EquipmentSet.GetNumEquipmentSets() do
					local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs()
					local name, icon, _, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(equipmentSetIDs[i]);
					menuList[i + 1].text = format('|T%s:20:20:0:0:64:64:4:60:4:60|t  %s', icon, name)
					menuList[i + 1].func = function() if not InCombatLockdown() then C_EquipmentSet.UseEquipmentSet(equipmentSetIDs[i]) end end
				end
				EasyMenu(menuList, menuFrame, SetFrame, -4, -8, "MENU", 2)
				DropDownList1:SetScale(0.9)
				for _, region in pairs({DropDownList1MenuBackdrop:GetRegions()}) do					
					if region:IsObjectType("Texture") then
						region:SetScale(1.2)
					end
				end
				
			end
		end	

	end)

	local function addonTooltip(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")

		GameTooltip:AddLine("|cffFFFFFFLeft Click:|r Change Equipment Set")

		GameTooltip:Show()
	end

	SetFrame:SetScript("OnEnter", function()
		addonTooltip(SetFrame)
	end)
	SetFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	SetFrame:SetScript("OnEvent", function(self, event)
		if (event=="EQUIPMENT_SWAP_FINISHED") or (event=="EQUIPMENT_SETS_CHANGED") or (event=="PLAYER_ENTERING_WORLD") then
			C_Timer.After(0.6, function()
				update(self)
			end)
		end
	end)

	SetFrame:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
	SetFrame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
	SetFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Misc:Warmode()

	local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

	local Warmode = CreateFrame('Frame', 'Warmode', UIParent)
	Warmode:SetPoint("TOPLEFT", SetFrame, "TOPRIGHT", 25, -1)
	Warmode:SetWidth(58)
	Warmode:SetHeight(13)
	Warmode:EnableMouse(true)
	Warmode:RegisterEvent("PLAYER_ENTERING_WORLD")
	Warmode:RegisterEvent("PLAYER_FLAGS_CHANGED")

	Warmode.text = Warmode:CreateFontString(nil, 'BACKGROUND')
	Warmode.text:SetPoint("CENTER", Warmode)
	Warmode.text:SetFont(font, 13, "OUTLINE")
	Warmode.text:SetShadowOffset(1, -1)
	Warmode.text:SetShadowColor(0, 0, 0)

	local icon = "Interface\\PVPFrame\\Icons\\prestige-icon-3"
	local warmodeIcon = '|T'..icon..':24:24:0:0:64:64:4:60:4:60|t'

	local function WarmodeUpdate(self)
		local isWarmodeToggled = C_PvP:IsWarModeDesired()
		if isWarmodeToggled then
			Warmode.text:SetFormattedText('%s %s', warmodeIcon, ": |cff00ff00 ON")
		else
			Warmode.text:SetFormattedText('%s %s', warmodeIcon, ": |cffff0000 OFF")
		end
	end

	local function addonTooltip(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")

		local isWarmodeToggled = C_PvP:IsWarModeDesired()
		if isWarmodeToggled then
			GameTooltip:AddLine("Warmode: |cff00ff00 ON|r")
		else
			GameTooltip:AddLine("Warmode: |cffff0000 OFF|r")
		end

		if not C_PvP:CanToggleWarMode() then
			GameTooltip:AddLine("|cFFFF0000This can only be turned on or off in Orgrimmar.")
		end

		GameTooltip:Show()
	end

	Warmode:SetScript("OnEnter", function()
		addonTooltip(Warmode)
	end)
	Warmode:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	Warmode:SetScript("OnEvent", function(self, event, ...)
		if event=="PLAYER_ENTERING_WORLD" then
			Warmode:Show()
			WarmodeUpdate()
		elseif event == "PLAYER_FLAGS_CHANGED" then
			local unit = ...
			if unit == "player" then
				WarmodeUpdate()
			end
		end
	end)

	Warmode:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			if C_PvP:CanToggleWarMode() then
				C_PvP:ToggleWarMode()
			end
		end
	end)
end

function Misc:Dampening()
	local frame = CreateFrame("Frame", nil , UIParent)
	local _
	local FindAuraByName = AuraUtil.FindAuraByName
	local dampeningtext = GetSpellInfo(110310)


	frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:SetPoint("TOP", UIWidgetTopCenterContainerFrame, "BOTTOM", 0, 0)
	frame:SetSize(200, 11.38) --11,38 is the height of the remaining time
	frame.text = frame:CreateFontString(nil, "BACKGROUND")
	frame.text:SetFontObject(GameFontNormalSmall)
	frame.text:SetAllPoints()


	function frame:UNIT_AURA(unit)
		--     1	  2		3		4			5			6			7			8				9				  10		11			12				13				14		15		   16
		local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, noIdea, timeMod , percentage = FindAuraByName(dampeningtext, unit, "HARMFUL")

		if percentage then
			if not self:IsShown() then
				self:Show()
			end
			if self.dampening ~= percentage then
				self.dampening = percentage
				self.text:SetText(dampeningtext..": "..percentage.."%")
			end

		elseif self:IsShown() then
			self:Hide()
		end
	end

	function frame:PLAYER_ENTERING_WORLD()
		local _, instanceType = IsInInstance()
		if instanceType == "arena" then
			self:RegisterUnitEvent("UNIT_AURA", "player")
		else	
			self:UnregisterEvent("UNIT_AURA")
		end
	end
end

function Misc:HoverBind()
	local bind, localmacros = CreateFrame("Frame", "ncHoverBind", UIParent), 0

	SlashCmdList.MOUSEOVERBIND = function()
		if InCombatLockdown() then print("You can't bind keys in combat.") return end
		if not bind.loaded then
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
			local extrabutton = ExtraActionButton1:GetScript("OnClick")

			local function register(val)
				if val.IsProtected and val.GetObjectType and val.GetScript and val:GetObjectType()=="CheckButton" and val:IsProtected() then
					local script = val:GetScript("OnClick")
					if script==button or script==extrabutton then
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
end

function Misc:SafeQueue()
	local SafeQueue = CreateFrame("Frame")
	local queueTime
	local queue = 0
	local remaining = 0

	LFGDungeonReadyDialog.leaveButton:Hide()
	LFGDungeonReadyDialog.leaveButton.Show = function() end
	LFGDungeonReadyDialog.enterButton:ClearAllPoints()
	LFGDungeonReadyDialog.enterButton:SetPoint("BOTTOM", LFGDungeonReadyDialog, "BOTTOM", 0, 25)
	LFGDungeonReadyDialog.label:SetPoint("TOP", 0, -22)

	PVPReadyDialog.leaveButton:Hide()
	PVPReadyDialog.leaveButton.Show = function() end
	PVPReadyDialog.enterButton:ClearAllPoints()
	PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)
	PVPReadyDialog.label:SetPoint("TOP", 0, -22)

	local function Print(msg)
		DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99SafeQueue|r: " .. msg)
	end

	local function PrintTime()
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
					--PrintTime()
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

function Misc:AFK()
	-- Thanks Elvui
	-- Set Up AFK Camera
	local AFKCamera = CreateFrame('Frame', nil, WorldFrame);
	AFKCamera:SetAllPoints();
	AFKCamera:SetAlpha(0);
	AFKCamera.width, AFKCamera.height = AFKCamera:GetSize();
	AFKCamera.hidden = true;

	--[[
	    Handles turning on and off the AFK Camera

	    @ param boolean $spin Whether the spinning should be turned off
	    @ return void
	]]
	local function ToggleSpin(spin)
	    -- If the configuration is off or the player is in combat then just do nothing
	    if (InCombatLockdown()) then return; end

	    if (spin) then
	    	self.AFKMode:Show()
	        -- Refresh and Set the Player Model anims
	        AFKCamera.playerModel:SetUnit('player');
	        AFKCamera.playerModel:SetAnimation(0);
	        AFKCamera.playerModel:SetRotation(math.rad(-15));
	        AFKCamera.playerModel:SetCamDistanceScale(1.2);

	        -- Refresh and Set the Pet Model anims
	        AFKCamera.petModel:SetUnit('pet');
	        AFKCamera.petModel:SetAnimation(0);
	        AFKCamera.petModel:SetRotation(math.rad(45));
	        AFKCamera.petModel:SetCamDistanceScale(1.7);

	        -- Hide the PVE Frame if it is shown
	        if(PVEFrame and PVEFrame:IsShown()) then
	            AFKCamera.PvEIsOpen = true; -- Store that it was open so that we can automatically reopen it after
	            PVEFrame_ToggleFrame();
	        else
	            AFKCamera.PvEIsOpen = false;
	        end

	        -- Hide the UI and begin the camera spinning
	        UIParent:Hide();
	        AFKCamera.fadeInAnim:Play();
	        AFKCamera.hidden = false;
	        MoveViewRightStart(0.05);
	    else
	        if(AFKCamera.hidden == false) then
	        	self.AFKMode:Hide()
	            MoveViewRightStop();
	            UIParent:Show();
	            AFKCamera.fadeOutAnim:Play();

	            -- Reopen PVE Frame if it was open
	            if(AFKCamera.PvEIsOpen) then
	                PVEFrame_ToggleFrame();
	            end

	            AFKCamera.hidden = true;
	        end
	    end
	end

	self.AFKMode = CreateFrame("Frame", "AFKFrame")
	self.AFKMode:SetFrameLevel(1)
	self.AFKMode:SetScale(UIParent:GetScale())
	self.AFKMode:SetAllPoints(UIParent)
	self.AFKMode:Hide()
	self.AFKMode:EnableKeyboard(true)
	self.AFKMode:SetScript("OnKeyDown", OnKeyDown)

	self.AFKMode.chat = CreateFrame("ScrollingMessageFrame", nil, self.AFKMode)
	self.AFKMode.chat:SetSize(500, 250)
	self.AFKMode.chat:SetPoint("TOPLEFT", self.AFKMode, "TOPLEFT", 4, -4)
	self.AFKMode.chat:SetJustifyH("LEFT")
	self.AFKMode.chat:SetMaxLines(500)
	self.AFKMode.chat:EnableMouseWheel(true)
	self.AFKMode.chat:SetFading(false)
	self.AFKMode.chat:SetMovable(true)
	self.AFKMode.chat:EnableMouse(true)
	self.AFKMode.chat:RegisterForDrag("LeftButton")
	self.AFKMode.chat:SetScript("OnDragStart", self.AFKMode.chat.StartMoving)
	self.AFKMode.chat:SetScript("OnDragStop", self.AFKMode.chat.StopMovingOrSizing)
	self.AFKMode.chat:SetScript("OnMouseWheel", Chat_OnMouseWheel)
	self.AFKMode.chat:SetScript("OnEvent", Chat_OnEvent)

	self.AFKMode.bottom = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.bottom:SetFrameLevel(0)
	self.AFKMode.bottom:SetPoint("BOTTOM", self.AFKMode, "BOTTOM", 0, 0)
	self.AFKMode.bottom:SetWidth(GetScreenWidth() + (1*2))
	self.AFKMode.bottom:SetHeight(GetScreenHeight() * (1 / 10))

	local factionGroup = UnitFactionGroup("player");
	--factionGroup = "Alliance"
	local size, offsetX, offsetY = 140, -20, -16
	local nameOffsetX, nameOffsetY = -10, -28
	if factionGroup == "Neutral" then
		factionGroup = "Panda"
		size, offsetX, offsetY = 90, 15, 10
		nameOffsetX, nameOffsetY = 20, -5
	end

	local playername = UnitName("player")
	local _, playerclass = UnitClass("player")
	local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[playerclass] or RAID_CLASS_COLORS[playerclass]

	self.AFKMode.bottom.name = self.AFKMode.bottom:CreateFontString(nil, 'OVERLAY')
	self.AFKMode.bottom.name:SetFont(font, 90);
	self.AFKMode.bottom.name:SetFormattedText("%s", playername)
	self.AFKMode.bottom.name:SetPoint("TOPLEFT", self.AFKMode.bottom, "BOTTOMLEFT", nameOffsetX, nameOffsetY)
	self.AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b)

	-- Set Up the Player Model
	AFKCamera.playerModel = CreateFrame('PlayerModel', nil, AFKCamera);
	AFKCamera.playerModel:SetSize(AFKCamera.height * 0.6, AFKCamera.height * 1.1);
	AFKCamera.playerModel:SetPoint('BOTTOMRIGHT', AFKCamera.height * 0.1, -AFKCamera.height * 0.27);
	AFKCamera.playerModel:SetFacing(6)

	-- Pet model for Hunters, Warlocks etc
	AFKCamera.petModel = CreateFrame('playerModel', nil, AFKCamera);
	AFKCamera.petModel:SetSize(AFKCamera.height * 0.7, AFKCamera.height);
	AFKCamera.petModel:SetPoint('BOTTOMLEFT', AFKCamera.height * 0.05, -AFKCamera.height * 0.3);

	-- Initialise the fadein / out anims
	AFKCamera.fadeInAnim = AFKCamera:CreateAnimationGroup();
	AFKCamera.fadeIn = AFKCamera.fadeInAnim:CreateAnimation('Alpha');
	AFKCamera.fadeIn:SetDuration(0.5);
	AFKCamera.fadeIn:SetFromAlpha(0);
	AFKCamera.fadeIn:SetToAlpha(1);
	AFKCamera.fadeIn:SetOrder(1);
	AFKCamera.fadeInAnim:SetScript('OnFinished', function() AFKCamera:SetAlpha(1) end );

	AFKCamera.fadeOutAnim = AFKCamera:CreateAnimationGroup();
	AFKCamera.fadeOut = AFKCamera.fadeOutAnim:CreateAnimation('Alpha');
	AFKCamera.fadeOut:SetDuration(0);
	AFKCamera.fadeOut:SetFromAlpha(1);
	AFKCamera.fadeOut:SetToAlpha(0);
	AFKCamera.fadeOut:SetOrder(1);
	AFKCamera.fadeOutAnim:SetScript('OnFinished', function() AFKCamera:SetAlpha(0) end );

	local function HandleEvents (self, event, ...)
	    if (event == 'PLAYER_FLAGS_CHANGED') then
			if (... =='player') then
				if (UnitIsAFK(...) and not UnitIsDead(...)) then
					ToggleSpin(true);
				else
					ToggleSpin(false);
				end
			end
		elseif (event == 'PLAYER_LEAVING_WORLD') then
			if (UnitIsAFK('player')) then
				ToggleSpin(false);
			end
		elseif (event == 'PLAYER_DEAD') then
			if (UnitIsAFK('player')) then
				ToggleSpin(false);
			end
		elseif (event == 'UPDATE_BATTLEFIELD_STATUS') then
			if (UnitIsAFK('player')) then
				ToggleSpin(false);
			end
	    end
	end

	-- Register the Modules Events
	AFKCamera:SetScript('OnEvent', HandleEvents);
	AFKCamera:RegisterEvent('PLAYER_FLAGS_CHANGED');
	AFKCamera:RegisterEvent('UPDATE_BATTLEFIELD_STATUS')
	AFKCamera:RegisterEvent('PLAYER_LEAVING_WORLD');
	AFKCamera:RegisterEvent('PLAYER_DEAD');
end

function Misc:ItemLevel()
	local MAJOR, MINOR = "ItemLevel", 1
	local ItemLevel = LibStub:NewLibrary(MAJOR, MINOR)

	if not ItemLevel then
	    return
	end

	local ItemLevelPattern = gsub(ITEM_LEVEL, "%%d", "(%%d+)")

	local tooltip = CreateFrame("GameTooltip", "LibItemLevelTooltip1", UIParent, "GameTooltipTemplate")
	local unittip = CreateFrame("GameTooltip", "LibItemLevelTooltip2", UIParent, "GameTooltipTemplate")

	function ItemLevel:hasLocally(ItemID)
	    if (not ItemID or ItemID == "" or ItemID == "0") then
	        return true
	    end
	    return select(10, GetItemInfo(tonumber(ItemID)))
	end

	function ItemLevel:itemLocally(ItemLink)
	    local id, gem1, gem2, gem3 = string.match(ItemLink, "item:(%d+):[^:]*:(%d-):(%d-):(%d-):")
	    return (self:hasLocally(id) and self:hasLocally(gem1) and self:hasLocally(gem2) and self:hasLocally(gem3))
	end

	function ItemLevel:GetItemInfo(ItemLink)
	    if (not ItemLink or ItemLink == "") then
	        return 0, 0
	    end
	    if (not string.match(ItemLink, "item:%d+:")) then
	        return -1, 0
	    end
	    if (not self:itemLocally(ItemLink)) then
	        return 1, 0
	    end
	    local level, text
	    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	    tooltip:ClearLines()
	    tooltip:SetHyperlink(ItemLink)
	    for i = 2, 5 do
	        text = _G[tooltip:GetName() .. "TextLeft" .. i]:GetText() or ""
	        level = string.match(text, ItemLevelPattern)
	        if (level) then
	            break
	        end
	    end
	    return 0, tonumber(level) or 0, GetItemInfo(ItemLink)
	end

	LibItemLevel = LibStub:GetLibrary("ItemLevel");

	function ItemLevel:GetUnitItemInfo(unit, index)
	    if (not UnitExists(unit)) then
	        return 1, 0
	    end
	    unittip:SetOwner(UIParent, "ANCHOR_NONE")
	    unittip:ClearLines()
	    unittip:SetInventoryItem(unit, index)
	    local ItemLink = select(2, unittip:GetItem())
	    if (not ItemLink or ItemLink == "") then
	        return 0, 0
	    end
	    if (not self:itemLocally(ItemLink)) then
	        return 1, 0
	    end
	    local level, text
	    for i = 2, 5 do
	        text = _G[unittip:GetName() .. "TextLeft" .. i]:GetText() or ""
	        level = string.match(text, ItemLevelPattern)
	        if (level) then
	            break
	        end
	    end
	    return 0, tonumber(level) or 0, GetItemInfo(ItemLink)
	end

	function ItemLevel:GetUnitItemLevel(unit)
	    local total, counts = 0, 0
	    local _, count, level
	    for i = 1, 15 do
	        if (i ~= 4) then
	            count, level = self:GetUnitItemInfo(unit, i)
	            total = total + level
	            counts = counts + count
	        end
	    end
	    local mcount, mlevel, mquality, mslot, ocount, olevel, oquality, oslot
	    mcount, mlevel, _, _, mquality, _, _, _, _, _, mslot = self:GetUnitItemInfo(unit, 16)
	    ocount, olevel, _, _, oquality, _, _, _, _, _, oslot = self:GetUnitItemInfo(unit, 17)
	    counts = counts + mcount + ocount

	    if (mquality == 6 or oslot == "INVTYPE_2HWEAPON" or mslot == "INVTYPE_2HWEAPON" or mslot == "INVTYPE_RANGED" or mslot == "INVTYPE_RANGEDRIGHT") then
	        total = total + max(mlevel, olevel) * 2
	    else
	        total = total + mlevel + olevel
	    end
	    return counts, total / (16 - counts), total
	end

	function ShowPaperDollItemLevel(self, unit)
	    result = "";
	    id = self:GetID();
	    if id == 4 or id > 17 then
	        return
	    end;
	    if not self.levelString then
	        self.levelString = self:CreateFontString(nil, "OVERLAY");
	        self.levelString:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
	        self.levelString:SetPoint("TOP");
	        self.levelString:SetTextColor(1, 0.82, 0);
	    end;
	    if unit and self.hasItem then
	        _, level, _, _, quality = LibItemLevel:GetUnitItemInfo(unit, id);
	        if level > 0 and quality > 1 then
	            self.levelString:SetText(level);
	            result = true;
	        end;
	    else
	        self.levelString:SetText("");
	        result = true;
	    end;
	    if id == 16 or id == 17 then
	        _, offhand, _, _, quality = LibItemLevel:GetUnitItemInfo(unit, 17);
	        if quality == 6 then
	            _, mainhand = LibItemLevel:GetUnitItemInfo(unit, 16);
	            self.levelString:SetText(math.max(mainhand, offhand));
	        end;
	    end;
	    return result;
	end;
	hooksecurefunc("PaperDollItemSlotButton_Update", function(self)
	    ShowPaperDollItemLevel(self, "player");
	end);

	function SetContainerItemLevel(button, ItemLink)
	    if not button then
	        return
	    end;
	    if not button.levelString then
	        button.levelString = button:CreateFontString(nil, "OVERLAY");
	        button.levelString:SetFont(STANDARD_TEXT_FONT, 12, "THICKOUTLINE");
	        button.levelString:SetPoint("TOP");
	    end;
	    if button.origItemLink ~= ItemLink then
	        button.origItemLink = ItemLink;
	    else return
	    end;
	    if ItemLink then
	        count, level, _, _, quality, _, _, class, subclass, _, _ = LibItemLevel:GetItemInfo(ItemLink);
	        name, _ = GetItemSpell(ItemLink);
	        _, equipped, _ = GetAverageItemLevel();
	        if level >= (80 * equipped / 100) then
	            button.levelString:SetTextColor(1, 0.82, 0);
	        else
	            button.levelString:SetTextColor(0.5, 0.5, 0.5);
	        end;
	        if count == 0 and level > 0 and quality > 1 then
	            button.levelString:SetText(level);
	        else
	            button.levelString:SetText("");
	        end;
	    else
	        button.levelString:SetText("");
	    end;
	end;
	hooksecurefunc("ContainerFrame_Update", function(self)
	    local name = self:GetName();
	    for i = 1, self.size do
	        local button = _G[name .. "Item" .. i];
	        SetContainerItemLevel(button, GetContainerItemLink(self:GetID(), button:GetID()));
	    end;
	end);
end

function Misc:Surrender()
	local function Print(msg)
		print("|cFF40E0D0"..msg.."|r")
	end

	SlashCmdList["CHAT_AFK"] = function(msg)
		if IsActiveBattlefieldArena() then
			if CanSurrenderArena() then
				Print("Successfully surrendered arena.")
				SurrenderArena();
			else
				Print("Failed to surrender arena. Partners still alive.")
			end
		else
			SendChatMessage(msg, "AFK");
		end
	end
end

function Misc:TeleportCloak()

	-- TeleportCloak by Jordon

	local TeleportCloak = CreateFrame("Frame")
	TeleportCloak:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

	local List = {
		Cloak = {
			65274, -- Cloak of Coordination (Horde)
			65360, -- Cloak of Coordination (Alliance)
			63206, -- Wrap of Unity (Alliance)
			63207, -- Wrap of Unity (Horde)
			63352, -- Shroud of Cooperation (Alliance)
			63353, -- Shroud of Cooperation (Horde)
		},
		Trinket = {
			103678, -- Time-Lost Artifact
			17691, -- Stormpike Insignia Rank 1
			17900, -- Stormpike Insignia Rank 2
			17901, -- Stormpike Insignia Rank 3
			17902, -- Stormpike Insignia Rank 4
			17903, -- Stormpike Insignia Rank 5
			17904, -- Stormpike Insignia Rank 6
			17690, -- Frostwolf Insignia Rank 1
			17905, -- Frostwolf Insignia Rank 2
			17906, -- Frostwolf Insignia Rank 3
			17907, -- Frostwolf Insignia Rank 4
			17908, -- Frostwolf Insignia Rank 5
			17909, -- Frostwolf Insignia Rank 6
		},
		Ring = {
			40585, -- Signet of the Kirin Tor
			40586, -- Band of the Kirin Tor
			44934, -- Loop of the Kirin Tor
			44935, -- Ring of the Kirin Tor
			45688, -- Inscribed Band of the Kirin Tor
			45689, -- Inscribed Loop of the Kirin Tor
			45690, -- Inscribed Ring of the Kirin Tor
			45691, -- Inscribed Signet of the Kirin Tor
			48954, -- Etched Band of the Kirin Tor
			48955, -- Etched Loop of the Kirin Tor
			48956, -- Etched Ring of the Kirin Tor
			48957, -- Etched Signet of the Kirin Tor
			51557, -- Runed Signet of the Kirin Tor
			51558, -- Runed Loop of the Kirin Tor
			51559, -- Runed Ring of the Kirin Tor
			51560, -- Runed Band of the Kirin Tor
			95050, -- Brassiest Knuckle (Horde)
			144392, -- Brawler's Guild Ring
			95051, -- Brassiest Knuckle (Alliance)
		},
		Feet = {
			50287, -- Boots of the Bay
			28585, -- Ruby Slippers
		},
		Neck = {
			32757, -- Blessed Medallion of Karabor
		},
		Tabard = {
			46874, -- Argent Crusader's Tabard
			63378, -- Hellscream's Reach Tabard
			63379, -- Baradin's Wardens Tabard
		}
	}

	local InventoryType = {
		INVTYPE_NECK = INVSLOT_NECK,
		INVTYPE_FEET = INVSLOT_FEET,
		INVTYPE_FINGER = INVSLOT_FINGER1,
		INVTYPE_TRINKET = INVSLOT_TRINKET1,
		INVTYPE_CLOAK = INVSLOT_BACK,
		INVTYPE_TABARD = INVSLOT_TABARD,
	}

	local function IsTeleportItem(item)
		for slot,_ in pairs(List) do
			for j=1, #List[slot] do
				if List[slot][j] == item then return true end
			end
		end
		return false
	end

	local TeleportCloakList = {}

	TeleportCloakWarnings = TeleportCloakWarnings or true


	local function Print(msg, subTitle, skipTitle)
		local title = "|cff33ff99TeleportCloak|r"
		if subTitle then
			if not skipTitle then DEFAULT_CHAT_FRAME:AddMessage(title) end
			DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99" .. subTitle .. "|r: " .. msg)
		else
			DEFAULT_CHAT_FRAME:AddMessage(title .. ": " .. msg)
		end
	end

	local Slots = {
		INVSLOT_NECK,
		INVSLOT_FEET,
		INVSLOT_FINGER1,
		INVSLOT_FINGER2,
		INVSLOT_TRINKET1,
		INVSLOT_TRINKET2,
		INVSLOT_BACK,
		INVSLOT_TABARD,
	}

	local Saved = {}

	local function SaveItems()
		for i=1, #Slots do
			local item = GetInventoryItemID("player", Slots[i])
			if item and not IsTeleportItem(item) then
				Saved[Slots[i]] = item
			end
		end
	end
	TeleportCloak:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	TeleportCloak.PLAYER_EQUIPMENT_CHANGED = SaveItems
	TeleportCloak:RegisterEvent("PLAYER_ENTERING_WORLD")
	TeleportCloak.PLAYER_ENTERING_WORLD = SaveItems

	local function RestoreItems()
		for i=1, #Slots do
			local item = GetInventoryItemID("player", Slots[i])
			if item and IsTeleportItem(item) then
				if Saved[Slots[i]] and not InCombatLockdown() then
					EquipItemByName(Saved[Slots[i]])
				elseif TeleportCloakWarnings then
					if Slots[i] ~= INVSLOT_TABARD then
						Print("|cffff0000Warning|r: " .. GetItemInfo(item))
					end
				end
			end
		end
	end

	TeleportCloak:RegisterEvent("ZONE_CHANGED")
	TeleportCloak.ZONE_CHANGED = RestoreItems
	TeleportCloak:RegisterEvent("ZONE_CHANGED_INDOORS")
	TeleportCloak.ZONE_CHANGED_INDOORS = RestoreItems
	TeleportCloak:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	TeleportCloak.ZONE_CHANGED_NEW_AREA = RestoreItems
end

function Misc:Quests()

	local mapIDs = {
		862, -- Zuldazar
		863, -- Nazmir
		864, -- Voldun
		1165, -- Zuldazar (Dazar'alor)
	}
	 -- Hook objective tracker
	
	function SetBlockHeader_hook()
	  for i = 1, GetNumQuestWatches() do
	   local questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete, failureTime, timeElapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(i)
	   if ( not questID ) then
	    break
	   end
	   local oldBlock = QUEST_TRACKER_MODULE:GetExistingBlock(questID)
	   if oldBlock then
	    local oldBlockHeight = oldBlock.height
	    local oldHeight = QUEST_TRACKER_MODULE:SetStringText(oldBlock.HeaderText, title, nil, OBJECTIVE_TRACKER_COLOR["Header"])

	    local newTitle = title
	    
	    local playerMap = C_Map.GetBestMapForUnit("player")
	    local questLine 
	    if playerMap then
	    	questline = C_QuestLine.GetQuestLineInfo(questID, playerMap)
		    if not questLine then
		    	for k, j in pairs(mapIDs) do
		    		local questLine = C_QuestLine.GetQuestLineInfo(questID, k)
		    		if questLine then
		    			newTitle = "["..questLine["questLineName"].."] "..title
		    		end
		    	end
		    end
	   	end
	      

	    local newHeight = QUEST_TRACKER_MODULE:SetStringText(oldBlock.HeaderText, newTitle, nil, OBJECTIVE_TRACKER_COLOR["Header"])
	    oldBlock:SetHeight(oldBlockHeight + newHeight - oldHeight);
	   end
	  end
	end
	hooksecurefunc(QUEST_TRACKER_MODULE, "Update", SetBlockHeader_hook)

	local QuestNum = CreateFrame("Frame")
	QuestNum:RegisterEvent("PLAYER_ENTERING_WORLD")
	QuestNum:RegisterEvent("QUEST_LOG_UPDATE")
	QuestNum:SetScript("OnEvent", function()
		local _, N = GetNumQuestLogEntries()
 		ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetText("Quests : "..N.."/25")
 		ObjectiveTrackerFrame.HeaderMenu.Title:SetText("Quests : "..N.."/25")
 	end)
end

function Misc:SkipCinematic()

	CinematicFrame:HookScript("OnShow", function(self, ...)
	  if IsModifierKeyDown() then return end
	  CinematicFrame_CancelCinematic()
	end)

	local omfpf = _G["MovieFrame_PlayMovie"]
	_G["MovieFrame_PlayMovie"] = function(...)
	  if IsModifierKeyDown() then return omfpf(...) end
	  GameMovieFinished()
	  return true
	end
end

function Misc:ExtraActionButton()

	-- Quests with incorrect or missing quest area blobs
	local questAreas = {
		-- Global
		[24629] = true,

		-- Icecrown
		[14108] = 541,

		-- Northern Barrens
		[13998] = 11,

		-- Un'Goro Crater
		[24735] = 201,

		-- Darkmoon Island
		[29506] = 823,
		[29510] = 823,

		-- Mulgore
		[24440] = 9,
		[14491] = 9,
		[24456] = 9,
		[24524] = 9,

		-- Mount Hyjal
		[25577] = 606,
	}

	-- Quests items with incorrect or missing quest area blobs
	local itemAreas = {
		-- Global
		[34862] = true,
		[34833] = true,
		[39700] = true,

		-- Deepholm
		[58167] = 640,
		[60490] = 640,

		-- Ashenvale
		[35237] = 43,

		-- Thousand Needles
		[56011] = 61,

		-- Tanaris
		[52715] = 161,

		-- The Jade Forest
		[84157] = 806,
		[89769] = 806,

		-- Hellfire Peninsula
		[28038] = 465,
		[28132] = 465,

		-- Borean Tundra
		[35352] = 486,
		[34772] = 486,
		[34711] = 486,
		[35288] = 486,
		[34782] = 486,

		-- Zul'Drak
		[41161] = 496,
		[39157] = 496,
		[39206] = 496,
		[39238] = 496,
		[39664] = 496,
		[38699] = 496,
		[41390] = 496,

		-- Dalaran (Broken Isles)
		[129047] = 1014,

		-- Stormheim
		[128287] = 1017,
		[129161] = 1017,

		-- Azsuna
		[118330] = 1015,

		-- Suramar
		[133882] = 1033,
	}

	local ExtraActionButton = CreateFrame('Button', 'ExtraActionButton', UIParent, 'SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerAttributeTemplate')
	ExtraActionButton:SetMovable(true)
	ExtraActionButton:RegisterEvent('PLAYER_LOGIN')
	ExtraActionButton:SetScript('OnEvent', function(self, event, ...)
		if(self[event]) then
			self[event](self, event, ...)
		elseif(self:IsEnabled()) then
			self:Update()
		end
	end)

	local visibilityState = '[extrabar][petbattle] hide; show'
	local onAttributeChanged = [[
		if(name == 'item') then
			if(value and not self:IsShown() and not HasExtraActionBar()) then
				self:Show()
			elseif(not value) then
				self:Hide()
				self:ClearBindings()
			end
		elseif(name == 'state-visible') then
			if(value == 'show') then
				self:CallMethod('Update')
			else
				self:Hide()
				self:ClearBindings()
			end
		end

		if(self:IsShown() and (name == 'item' or name == 'binding')) then
			self:ClearBindings()

			local key = GetBindingKey('EXTRAACTIONBUTTON1')
			if(key) then
				self:SetBindingClick(1, key, self, 'LeftButton')
			end
		end
	]]

	function ExtraActionButton:BAG_UPDATE_COOLDOWN()
		if(self:IsShown() and self:IsEnabled()) then
			local start, duration, enable = GetItemCooldown(self.itemID)
			if(duration > 0) then
				self.Cooldown:SetCooldown(start, duration)
				self.Cooldown:Show()
			else
				self.Cooldown:Hide()
			end
		end
	end

	function ExtraActionButton:BAG_UPDATE_DELAYED()
		self:Update()

		if(self:IsShown() and self:IsEnabled()) then
			local count = GetItemCount(self.itemLink)
			self.Count:SetText(count and count > 1 and count or '')
		end
	end

	function ExtraActionButton:PLAYER_REGEN_ENABLED(event)
		self:SetAttribute('item', self.attribute)
		self:UnregisterEvent(event)
		self:BAG_UPDATE_COOLDOWN()
	end

	function ExtraActionButton:UPDATE_BINDINGS()
		if(self:IsShown() and self:IsEnabled()) then
			self:SetItem()
			self:SetAttribute('binding', GetTime())
		end
	end

	function ExtraActionButton:PLAYER_LOGIN()
		RegisterStateDriver(self, 'visible', visibilityState)
		self:SetAttribute('_onattributechanged', onAttributeChanged)
		self:SetAttribute('type', 'item')

		if(not self:GetPoint()) then
			self:SetPoint('CENTER', ExtraActionButton1)
		end

		self:SetSize(ExtraActionButton1:GetSize())
		self:SetScale(ExtraActionButton1:GetScale())
		self:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]])
		self:SetPushedTexture([[Interface\Buttons\CheckButtonHilight]])
		self:GetPushedTexture():SetBlendMode('ADD')
		self:SetScript('OnLeave', GameTooltip_Hide)
		self:SetClampedToScreen(true)
		self:SetToplevel(true)

		self.updateTimer = 0
		self.rangeTimer = 0
		self:Hide()

		local Icon = self:CreateTexture('$parentIcon', 'BACKGROUND')
		Icon:SetAllPoints()
		self.Icon = Icon

		local HotKey = self:CreateFontString('$parentHotKey', nil, 'NumberFontNormalGray')
		HotKey:SetPoint('BOTTOMRIGHT', -5, 5)
		self.HotKey = HotKey

		local Count = self:CreateFontString('$parentCount', nil, 'NumberFontNormal')
		Count:SetPoint('TOPLEFT', 7, -7)
		self.Count = Count

		local Cooldown = CreateFrame('Cooldown', '$parentCooldown', self, 'CooldownFrameTemplate')
		Cooldown:ClearAllPoints()
		Cooldown:SetPoint('TOPRIGHT', -2, -3)
		Cooldown:SetPoint('BOTTOMLEFT', 2, 1)
		Cooldown:Hide()
		self.Cooldown = Cooldown

		local Artwork = self:CreateTexture('$parentArtwork', 'OVERLAY')
		Artwork:SetPoint('CENTER', -2, 0)
		Artwork:SetSize(256, 128)
		Artwork:SetTexture([[Interface\ExtraButton\Default]])
		self.Artwork = Artwork

		self:RegisterEvent('UPDATE_BINDINGS')
		self:RegisterEvent('BAG_UPDATE_COOLDOWN')
		self:RegisterEvent('BAG_UPDATE_DELAYED')
		--self:RegisterEvent('WORLD_MAP_UPDATE')
		self:RegisterEvent('QUEST_LOG_UPDATE')
		self:RegisterEvent('QUEST_POI_UPDATE')
		self:RegisterEvent('AREA_POIS_UPDATED')
		self:RegisterEvent('QUEST_WATCH_LIST_CHANGED')
		self:RegisterEvent('QUEST_ACCEPTED')
		self:RegisterEvent('ZONE_CHANGED')
		self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
	end

	local worldQuests = {}
	function ExtraActionButton:QUEST_REMOVED(event, questID)
		if(worldQuests[questID]) then
			worldQuests[questID] = nil

			self:Update()
		end
	end

	function ExtraActionButton:QUEST_ACCEPTED(event, questLogIndex, questID)
		if(questID and not IsQuestBounty(questID) and IsQuestTask(questID)) then
			local _, _, worldQuestType = GetQuestTagInfo(questID)
			if(worldQuestType and not worldQuests[questID]) then
				worldQuests[questID] = questLogIndex

				self:Update()
			end
		end
	end

	ExtraActionButton:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
		GameTooltip:SetHyperlink(self.itemLink)
	end)

	ExtraActionButton:SetScript('OnUpdate', function(self, elapsed)
		if(not self:IsEnabled()) then
			return
		end

		if(self.rangeTimer > TOOLTIP_UPDATE_TIME) then
			local HotKey = self.HotKey

			-- BUG: IsItemInRange() is broken versus friendly npcs (and possibly others)
			local inRange = IsItemInRange(self.itemLink, 'target')
			if(HotKey:GetText() == RANGE_INDICATOR) then
				if(inRange == false) then
					HotKey:SetTextColor(1, 0.1, 0.1)
					HotKey:Show()
				elseif(inRange) then
					HotKey:SetTextColor(0.6, 0.6, 0.6)
					HotKey:Show()
				else
					HotKey:Hide()
				end
			else
				if(inRange == false) then
					HotKey:SetTextColor(1, 0.1, 0.1)
				else
					HotKey:SetTextColor(0.6, 0.6, 0.6)
				end
			end

			self.rangeTimer = 0
		else
			self.rangeTimer = self.rangeTimer + elapsed
		end

		if(self.updateTimer > 5) then
			self:Update()
			self.updateTimer = 0
		else
			self.updateTimer = self.updateTimer + elapsed
		end
	end)

	ExtraActionButton:SetScript('OnEnable', function(self)
		RegisterStateDriver(self, 'visible', visibilityState)
		self:SetAttribute('_onattributechanged', onAttributeChanged)
		self.Artwork:SetTexture([[Interface\ExtraButton\Default]])
		self:Update()
		self:SetItem()
	end)

	ExtraActionButton:SetScript('OnDisable', function(self)
		if(not self:IsMovable()) then
			self:SetMovable(true)
		end

		RegisterStateDriver(self, 'visible', 'show')
		self:SetAttribute('_onattributechanged', nil)
		self.Icon:SetTexture([[Interface\Icons\INV_Misc_Wrench_01]])
		self.Artwork:SetTexture([[Interface\ExtraButton\Ultraxion]])
		self.HotKey:Hide()
	end)

	-- Sometimes blizzard does actually do what I want
	local blacklist = {
		[113191] = true,
		[110799] = true,
		[109164] = true,
	}

	function ExtraActionButton:SetItem(itemLink, texture)
		if(HasExtraActionBar()) then
			return
		end

		if(itemLink) then
			self.Icon:SetTexture(texture)

			if(itemLink == self.itemLink and self:IsShown()) then
				return
			end

			local itemID, itemName = string.match(itemLink, '|Hitem:(.-):.-|h%[(.+)%]|h')
			self.itemID = tonumber(itemID)
			self.itemName = itemName
			self.itemLink = itemLink

			if(blacklist[itemID]) then
				return
			end
		end

		local HotKey = self.HotKey
		local key = GetBindingKey('EXTRAACTIONBUTTON1')
		if(key) then
			HotKey:SetText(GetBindingText(key, 1))
			HotKey:Show()
		elseif(ItemHasRange(itemLink)) then
			HotKey:SetText(RANGE_INDICATOR)
			HotKey:Show()
		else
			HotKey:Hide()
		end

		if(InCombatLockdown()) then
			self.attribute = self.itemName
			self:RegisterEvent('PLAYER_REGEN_ENABLED')
		else
			self:SetAttribute('item', self.itemName)
			self:BAG_UPDATE_COOLDOWN()
		end
	end

	function ExtraActionButton:RemoveItem()
		if(InCombatLockdown()) then
			self.attribute = nil
			self:RegisterEvent('PLAYER_REGEN_ENABLED')
		else
			self:SetAttribute('item', nil)
		end
	end

	local function GetClosestQuestItem()
		-- Basically a copy of QuestSuperTracking_ChooseClosestQuest from Blizzard_ObjectiveTracker
		local closestQuestLink, closestQuestTexture
		local shortestDistanceSq = 62500 -- 250 yards²
		local numItems = 0

		-- XXX: temporary solution for the above
		for questID, questLogIndex in next, worldQuests do
			local itemLink, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
			if(itemLink) then
				local areaID = questAreas[questID]
				if(not areaID) then
					areaID = itemAreas[tonumber(string.match(itemLink, 'item:(%d+)'))]
				end

				local _, _, _, _, _, isComplete = GetQuestLogTitle(questLogIndex)
				if(areaID and (type(areaID) == 'boolean' or areaID == C_Map.GetBestMapForUnit("player"))) then
					closestQuestLink = itemLink
					closestQuestTexture = texture
				elseif(not isComplete or (isComplete and showCompleted)) then
					local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)
					if(onContinent and distanceSq <= shortestDistanceSq) then
						shortestDistanceSq = distanceSq
						closestQuestLink = itemLink
						closestQuestTexture = texture
					end
				end

				numItems = numItems + 1
			end
		end

		if(not closestQuestLink) then
			for index = 1, GetNumQuestWatches() do
				local questID, _, questLogIndex, _, _, isComplete = GetQuestWatchInfo(index)
				if(questID and QuestHasPOIInfo(questID)) then
					local itemLink, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
					if(itemLink) then
						local areaID = questAreas[questID]
						if(not areaID) then
							areaID = itemAreas[tonumber(string.match(itemLink, 'item:(%d+)'))]
						end

						if(areaID and (type(areaID) == 'boolean' or areaID == C_Map.GetBestMapForUnit("player"))) then
							closestQuestLink = itemLink
							closestQuestTexture = texture
						elseif(not isComplete or (isComplete and showCompleted)) then
							local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)
							if(onContinent and distanceSq <= shortestDistanceSq) then
								shortestDistanceSq = distanceSq
								closestQuestLink = itemLink
								closestQuestTexture = texture
							end
						end

						numItems = numItems + 1
					end
				end
			end
		end

		if(not closestQuestLink) then
			for questLogIndex = 1, GetNumQuestLogEntries() do
				local _, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(questLogIndex)
				if(not isHeader and QuestHasPOIInfo(questID)) then
					local itemLink, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
					if(itemLink) then
						local areaID = questAreas[questID]
						if(not areaID) then
							areaID = itemAreas[tonumber(string.match(itemLink, 'item:(%d+)'))]
						end

						if(areaID and (type(areaID) == 'boolean' or areaID == C_Map.GetBestMapForUnit("player"))) then
							closestQuestLink = itemLink
							closestQuestTexture = texture
						elseif(not isComplete or (isComplete and showCompleted)) then
							local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)
							if(onContinent and distanceSq <= shortestDistanceSq) then
								shortestDistanceSq = distanceSq
								closestQuestLink = itemLink
								closestQuestTexture = texture
							end
						end

						numItems = numItems + 1
					end
				end
			end
		end

		return closestQuestLink, closestQuestTexture, numItems
	end

	local ticker
	function ExtraActionButton:Update()
		if(not self:IsEnabled() or self.locked) then
			return
		end

		local itemLink, texture, numItems = GetClosestQuestItem()
		if(itemLink) then
			self:SetItem(itemLink, texture)
		elseif(self:IsShown()) then
			self:RemoveItem()
		end

		if(numItems > 0 and not ticker) then
			ticker = C_Timer.NewTicker(30, function() -- might want to lower this
				ExtraActionButton:Update()
			end)
		elseif(numItems == 0 and ticker) then
			ticker:Cancel()
			ticker = nil
		end
	end

	local locked = true
	local moving = nil

	local Drag = CreateFrame('Frame', nil, ExtraActionButton)
	Drag:SetAllPoints()
	Drag:SetFrameStrata('HIGH')
	Drag:EnableMouse(true)
	Drag:RegisterForDrag('LeftButton')
	Drag:Hide()

	ExtraActionButton1:SetPoint(Misc.settings.ExtraActionButton.point, UIParent, Misc.settings.ExtraActionButton.point, Misc.settings.ExtraActionButton.x, Misc.settings.ExtraActionButton.y)

	Drag:SetScript("OnMouseDown", function(self, button)
		if locked then return end
		if button == "LeftButton" then
			ExtraActionButton:ClearAllPoints()
			ExtraActionButton:StartMoving()
			moving = true
		end
	end)

	Drag:SetScript("OnMouseUp", function(self, button)
		if moving then
			moving = nil
			ExtraActionButton:StopMovingOrSizing()

			local point, _, _, x, y = ExtraActionButton:GetPoint(1)
			Misc.settings.ExtraActionButton.point = point
			Misc.settings.ExtraActionButton.x = x
			Misc.settings.ExtraActionButton.y = y

			ExtraActionButton1:SetPoint(Misc.settings.ExtraActionButton.point, UIParent, Misc.settings.ExtraActionButton.point, Misc.settings.ExtraActionButton.x, Misc.settings.ExtraActionButton.y)
		end
	end)

	Drag:SetScript('OnShow', function(self)
		ExtraActionButton:Disable()
		self:RegisterEvent('PLAYER_REGEN_DISABLED')
		ExtraActionButton:ClearAllPoints()
		ExtraActionButton:SetPoint(Misc.settings.ExtraActionButton.point, Misc.settings.ExtraActionButton.x, Misc.settings.ExtraActionButton.y)
	end)

	Drag:SetScript('OnHide', function(self)
		ExtraActionButton:Enable()
		self:UnregisterEvent('PLAYER_REGEN_DISABLED')
	end)

	Drag:SetScript('OnEvent', function(self)
		self:Hide()
		ExtraActionButton:StopMovingOrSizing()
	end)

	Drag:SetScript('OnDragStart', function()
		ExtraActionButton:StartMoving()
	end)

	Drag:SetScript('OnDragStop', function()
		ExtraActionButton:StopMovingOrSizing()
	end)

	function ExtraActionButton:Move()

		if locked == false then
			locked = true
			ExtraActionButton:SetFrameStrata("LOW")
			ExtraActionButton1:SetFrameStrata("LOW")
			MoveBackgroundFrame:Hide()
		else
			locked = false
			ExtraActionButton:SetFrameStrata("TOOLTIP")
			ExtraActionButton1:SetFrameStrata("TOOLTIP")
			MoveBackgroundFrame:SetFrameStrata("DIALOG")
			MoveBackgroundFrame:Show()
		end

		if(Drag:IsShown()) then
			Drag:Hide()
		else
			Drag:Show()
			ExtraActionButton:Show()
		end
	end
end

function Misc:PowerBarAlt()
	local PlayerPowerBarAlt = PlayerPowerBarAlt
	PlayerPowerBarAlt:SetMovable(true)
	PlayerPowerBarAlt:SetUserPlaced(true)

	local locked = true
	local moving = nil

	local overlay = CreateFrame("Frame", "PowerBarAlt", PlayerPowerBarAlt)
	overlay:SetAllPoints()
	overlay:EnableMouse(true)

	do
		local texture = overlay:CreateTexture()
		texture:SetAllPoints()
		texture:SetColorTexture(1, 1, 1, 0.1)
		texture:Hide()
		overlay.texture = texture
	end

	overlay:SetScript("OnMouseDown", function(self, button)
		if locked then return end
		if button == "LeftButton" then
			PlayerPowerBarAlt:ClearAllPoints()
			PlayerPowerBarAlt:StartMoving()
			moving = true
		end
	end)

	overlay:SetScript("OnMouseUp", function(self, button)
		if moving then
			moving = nil
			PlayerPowerBarAlt:StopMovingOrSizing()

			local point, _, _, x, y = PlayerPowerBarAlt:GetPoint(1)
			Misc.settings.PowerBarAlt.point = point
			Misc.settings.PowerBarAlt.x = x
			Misc.settings.PowerBarAlt.y = y
		end
	end)

	overlay:SetScript("OnShow", function()
		-- use the counterBar region for clicks if its shown
		if PlayerPowerBarAlt.counterBar:IsShown() then
			overlay:SetAllPoints(PlayerPowerBarAlt.counterBar)
		else
			overlay:SetAllPoints(PlayerPowerBarAlt)
		end

		local parent = PlayerPowerBarAlt:GetParent()
		PlayerPowerBarAlt:ClearAllPoints()
		PlayerPowerBarAlt:SetPoint(Misc.settings.PowerBarAlt.point, Misc.settings.PowerBarAlt.x, Misc.settings.PowerBarAlt.y)
	end)

	overlay:SetScript("OnHide", function()
		-- the last power value isn't cleared so it'll be shown if it isn't used again but the frame is (DMF counter/timer setup)
		PlayerPowerBarAlt.statusFrame.text:SetText("")
	end)

	overlay:SetScript("OnEnter", function() 
		UnitPowerBarAlt_OnEnter(PlayerPowerBarAlt) 
	end)

	overlay:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	overlay:SetScript("OnEvent", function(self, event, arg1)
		if event == "CVAR_UPDATE" and arg1 == "STATUS_TEXT_DISPLAY" then
			UnitPowerBarAltStatus_UpdateText(PlayerPowerBarAlt)
		end
	end)
	overlay:RegisterEvent("CVAR_UPDATE")

	function PowerBarAlt:Move()
		if locked == false then
			locked = true
			PlayerPowerBarAlt:SetMovable(false)
			overlay:SetFrameStrata("LOW")
			MoveBackgroundFrame:Hide()
		else
			locked = false
			PlayerPowerBarAlt:SetFrameStrata("TOOLTIP")
			PlayerPowerBarAlt:SetMovable(true)
			MoveBackgroundFrame:SetFrameStrata("DIALOG")
			MoveBackgroundFrame:Show()
		end
		
		if UnitAlternatePowerInfo("player") then return end -- don't mess with it if it's real!

		UnitPowerBarAlt_TearDown(PlayerPowerBarAlt)
		if not PlayerPowerBarAlt:IsShown() then
			-- good ol' maw of madness bar
			UnitPowerBarAlt_SetUp(PlayerPowerBarAlt, 26)
			local textureInfo = {
				frame = { "Interface\\UNITPOWERBARALT\\Darkmoon_Horizontal_Frame", 1, 1, 1 },
				background = { "Interface\\UNITPOWERBARALT\\Darkmoon_Horizontal_Bgnd", 1, 1, 1 },
				fill = { "Interface\\UNITPOWERBARALT\\Darkmoon_Horizontal_Fill", 0.16862745583057, 0.87450987100601, 0.24313727021217 },
				spark = { "Interface\\UNITPOWERBARALT\\Darkmoon_Horizontal_Spark", 1, 1, 1 },
				flash = { "Interface\\UNITPOWERBARALT\\Darkmoon_Horizontal_Flash", 1, 1, 1 },
			}
			for name, info in next, textureInfo do
				local texture = PlayerPowerBarAlt[name]
				local path, r, g, b = unpack(info)
				texture:SetTexture(path)
				texture:SetVertexColor(r, g, b)
			end

			PlayerPowerBarAlt.minPower = 0
			PlayerPowerBarAlt.maxPower = 100
			PlayerPowerBarAlt.range = PlayerPowerBarAlt.maxPower - PlayerPowerBarAlt.minPower
			PlayerPowerBarAlt.value = 50
			PlayerPowerBarAlt.displayedValue = PlayerPowerBarAlt.value
			TextStatusBar_UpdateTextStringWithValues(PlayerPowerBarAlt.statusFrame, PlayerPowerBarAlt.statusFrame.text, PlayerPowerBarAlt.displayedValue, PlayerPowerBarAlt.minPower, PlayerPowerBarAlt.maxPower)

			PlayerPowerBarAlt:UpdateFill()
			PlayerPowerBarAlt:Show()
		else
			UnitPowerBarAlt_TearDown(PlayerPowerBarAlt)
			PlayerPowerBarAlt:Hide()
		end
	end
end