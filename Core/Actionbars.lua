local classcolor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
local dominos = IsAddOnLoaded("Dominos")
local bartender4 = IsAddOnLoaded("Bartender4")

textures = {
    normal            = "Interface\\AddOns\\JokUI\\media\\textures\\gloss",
    flash             = "Interface\\AddOns\\JokUI\\media\\textures\\flash",
    hover             = "Interface\\AddOns\\JokUI\\media\\textures\\hover",
    pushed            = "Interface\\AddOns\\JokUI\\media\\textures\\pushed",
    checked           = "Interface\\AddOns\\JokUI\\media\\textures\\checked",
    equipped          = "Interface\\AddOns\\JokUI\\media\\textures\\gloss_grey",
    buttonback        = "Interface\\AddOns\\JokUI\\media\\textures\\button_background",
    buttonbackflat    = "Interface\\AddOns\\JokUI\\media\\textures\\button_background_flat",
    outer_shadow      = "Interface\\AddOns\\JokUI\\media\\textures\\outer_shadow",
}

  background = {
    showbg            = true,   --show an background image?
    showshadow        = true,   --show an outer shadow?
    useflatbackground = false,  --true uses plain flat color instead
    backgroundcolor   = { r = 0.2, g = 0.2, b = 0.2, a = 0.3},
    shadowcolor       = { r = 0, g = 0, b = 0, a = 0.9},
    classcolored      = false,
    inset             = 5,
  }

  color = {
    normal            = { r = 0.37, g = 0.3, b = 0.3, },
    equipped          = { r = 0.1, g = 0.5, b = 0.1, },
    classcolored      = false,
  }

  hotkeys = {
    fontsize          = 12,
    pos1              = { a1 = "TOPRIGHT", x = 0, y = 0 },
    pos2              = { a1 = "TOPLEFT", x = 0, y = 0 }, --important! two points are needed to make the hotkeyname be inside of the button
  }

  macroname = {
    show              = true,
    fontsize          = 10,
    pos1              = { a1 = "BOTTOMLEFT", x = 0, y = 0 },
    pos2              = { a1 = "BOTTOMRIGHT", x = 0, y = 0 }, --important! two points are needed to make the macroname be inside of the button
  }

  itemcount = {
    show              = true,
    fontsize          = 12,
    pos1              = { a1 = "BOTTOMRIGHT", x = 0, y = 0 },
  }

  cooldown = {
    spacing           = 0,
  }

--backdrop settings
local bgfile, edgefile = "", ""
if background.showshadow then edgefile = textures.outer_shadow end
if background.useflatbackground and background.showbg then bgfile = textures.buttonbackflat end

--backdrop
local backdrop = {
    bgFile = bgfile,
    edgeFile = edgefile,
    tile = false,
    tileSize = 32,
    edgeSize = background.inset,
    insets = {
      left = background.inset,
      right = background.inset,
      top = background.inset,
      bottom = background.inset,
    },
  }

  ---------------------------------------
  -- FUNCTIONS
  ---------------------------------------

if IsAddOnLoaded("Masque") and (dominos or bartender4) then
	return
end

local function applyBackground(bu)
  if not bu or (bu and bu.bg) then return end
  --shadows+background
  if bu:GetFrameLevel() < 1 then bu:SetFrameLevel(1) end
  if background.showbg or background.showshadow then
    bu.bg = CreateFrame("Frame", nil, bu)
    -- bu.bg:SetAllPoints(bu)
    bu.bg:SetPoint("TOPLEFT", bu, "TOPLEFT", -4, 4)
    bu.bg:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 4, -4)
    bu.bg:SetFrameLevel(bu:GetFrameLevel()-1)
    if background.showbg and not background.useflatbackground then
      local t = bu.bg:CreateTexture(nil,"BACKGROUND",-8)
      t:SetTexture(textures.buttonback)
      --t:SetAllPoints(bu)
      t:SetVertexColor(background.backgroundcolor.r,background.backgroundcolor.g,background.backgroundcolor.b,background.backgroundcolor.a)
    end
    bu.bg:SetBackdrop(backdrop)
    if background.useflatbackground then
      bu.bg:SetBackdropColor(background.backgroundcolor.r,background.backgroundcolor.g,background.backgroundcolor.b,background.backgroundcolor.a)
    end
    if background.showshadow then
      bu.bg:SetBackdropBorderColor(background.shadowcolor.r,background.shadowcolor.g,background.shadowcolor.b,background.shadowcolor.a)
    end
  end
end

  --style extraactionbutton
  local function styleExtraActionButton(bu)
    if not bu or (bu and bu.rabs_styled) then return end
    local name = bu:GetName() or bu:GetParent():GetName()
	local style = bu.style or bu.Style
	local icon = bu.icon or bu.Icon
	local cooldown = bu.cooldown or bu.Cooldown
    local ho = _G[name.."HotKey"]
    -- remove the style background theme
	style:SetTexture(nil)
    hooksecurefunc(style, "SetTexture", function(self, texture)
      if texture then
        --print("reseting texture: "..texture)
        self:SetTexture(nil)
      end
    end)
    --icon
    icon:SetTexCoord(0.1,0.9,0.1,0.9)
    --icon:SetAllPoints(bu)
	  icon:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
    --cooldown
    cooldown:SetAllPoints(icon)
    --hotkey
	if ho then
		ho:Hide()
	end
    --add button normaltexture
    bu:SetNormalTexture(textures.normal)
    local nt = bu:GetNormalTexture()
    nt:SetVertexColor(color.normal.r,color.normal.g,color.normal.b,1)
    nt:SetAllPoints(bu)
    --apply background
    --if not bu.bg then applyBackground(bu) end
	bu.Back = CreateFrame("Frame", nil, bu)
		bu.Back:SetPoint("TOPLEFT", bu, "TOPLEFT", -3, 3)
		bu.Back:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 3, -3)
		bu.Back:SetFrameLevel(bu:GetFrameLevel() - 1)
		bu.Back:SetBackdrop(backdrop)
		bu.Back:SetBackdropBorderColor(0, 0, 0, 0.9)
    bu.rabs_styled = true
  end

  --initial style func
    local function styleActionButton(bu)
    if not bu or (bu and bu.rabs_styled) then
      return
    end
    local action = bu.action
    local name = bu:GetName()
    local ic  = _G[name.."Icon"]
    local co  = _G[name.."Count"]
    local bo  = _G[name.."Border"]
    local ho  = _G[name.."HotKey"]
    local cd  = _G[name.."Cooldown"]
    local na  = _G[name.."Name"]
    local fl  = _G[name.."Flash"]
    local nt  = _G[name.."NormalTexture"]
    local fbg  = _G[name.."FloatingBG"]
    local fob = _G[name.."FlyoutBorder"]
    local fobs = _G[name.."FlyoutBorderShadow"]
    if fbg then fbg:Hide() end  --floating background
    --flyout border stuff
    if fob then fob:SetTexture(nil) end
    if fobs then fobs:SetTexture(nil) end
    bo:SetTexture(nil) --hide the border (plain ugly, sry blizz)
    --hotkey
    ho:SetFont(font, hotkeys.fontsize, "OUTLINE")
    ho:ClearAllPoints()
    ho:SetPoint(hotkeys.pos1.a1,bu,hotkeys.pos1.x,hotkeys.pos1.y)
    ho:SetPoint(hotkeys.pos2.a1,bu,hotkeys.pos2.x,hotkeys.pos2.y)
    --macro name
    na:SetFont(font, macroname.fontsize, "OUTLINE")
    na:ClearAllPoints()
    na:SetPoint(macroname.pos1.a1,bu,macroname.pos1.x,macroname.pos1.y)
    na:SetPoint(macroname.pos2.a1,bu,macroname.pos2.x,macroname.pos2.y)
    if not dominos and not bartender4 and not macroname.show then
      na:Hide()
    end
    --item stack count
    co:SetFont(font, itemcount.fontsize, "OUTLINE")
    co:ClearAllPoints()
    co:SetPoint(itemcount.pos1.a1,bu,itemcount.pos1.x,itemcount.pos1.y)
    if not dominos and not bartender4 and not itemcount.show then
      co:Hide()
    end
    --applying the textures
    fl:SetTexture(textures.flash)
    --bu:SetHighlightTexture(textures.hover)
    bu:SetPushedTexture(textures.pushed)
    --bu:SetCheckedTexture(textures.checked)
    bu:SetNormalTexture(textures.normal)
    if not nt then
      --fix the non existent texture problem (no clue what is causing this)
      nt = bu:GetNormalTexture()
    end
    --cut the default border of the icons and make them shiny
    ic:SetTexCoord(0.1,0.9,0.1,0.9)
    ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
    ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
    --adjust the cooldown frame
    cd:SetPoint("TOPLEFT", bu, "TOPLEFT", cooldown.spacing, -cooldown.spacing)
    cd:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -cooldown.spacing, cooldown.spacing)
    --apply the normaltexture
    if action and  IsEquippedAction(action) then
      --bu:SetNormalTexture(textures.equipped)
      nt:SetVertexColor(color.equipped.r,color.equipped.g,color.equipped.b,1)
    else
      bu:SetNormalTexture(textures.normal)
      -- nt:SetVertexColor(color.normal.r,color.normal.g,color.normal.b,1)
    end
    --make the normaltexture match the buttonsize
    nt:SetAllPoints(bu)
    --hook to prevent Blizzard from reseting our colors
    hooksecurefunc(nt, "SetVertexColor", function(nt, r, g, b, a)
      local bu = nt:GetParent()
      local action = bu.action
      --print("bu"..bu:GetName().."R"..r.."G"..g.."B"..b)
      if r==1 and g==1 and b==1 and action and (IsEquippedAction(action)) then
          nt:SetVertexColor(0.999,0.999,0.999,1)
      elseif r==0.5 and g==0.5 and b==1 then
        --blizzard oom color
          nt:SetVertexColor(0.499,0.499,0.999,1)
      elseif r==1 and g==1 and b==1 then
          nt:SetVertexColor(0.5,0.5,0.5,1)
      end
    end)
    --shadows+background
    if not bu.bg then applyBackground(bu) end
    bu.rabs_styled = true
    if bartender4 then --fix the normaltexture
      nt:SetTexCoord(0,1,0,1)
      nt.SetTexCoord = function() return end
      bu.SetNormalTexture = function() return end
    end
  end
  -- style leave button
  local function styleLeaveButton(bu)
    if not bu or (bu and bu.rabs_styled) then return end
	  --local region = select(1, bu:GetRegions())
	  local name = bu:GetName()
  	local nt = bu:GetNormalTexture()
	  local bo = bu:CreateTexture(name.."Border", "BACKGROUND", nil, -7)
  	nt:SetTexCoord(0.2,0.8,0.2,0.8)
  	nt:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
    nt:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
  	bo:SetTexture(textures.normal)
  	bo:SetTexCoord(0, 1, 0, 1)
  	bo:SetDrawLayer("BACKGROUND",- 7)
  	bo:SetVertexColor(0.4, 0.35, 0.35)
	  bo:ClearAllPoints()
	  bo:SetAllPoints(bu)
    --shadows+background
    if not bu.bg then applyBackground(bu) end
    bu.rabs_styled = true
  end

  -- PetActionBarFrame:ClearAllPoints()
  -- PetActionBarFrame:SetPoint("BOTTOM",MultiBarBottomLeft,"TOP",12,3)
  -- PetActionBarFrame.SetPoint = function() end

  --style pet buttons
  local function stylePetButton(bu)
    if not bu or (bu and bu.rabs_styled) then return end
    local name = bu:GetName()
    local ic  = _G[name.."Icon"]
    local fl  = _G[name.."Flash"]
    local nt  = _G[name.."NormalTexture2"]
    nt:SetAllPoints(bu)
    --applying color
    nt:SetVertexColor(color.normal.r,color.normal.g,color.normal.b,1)
    --setting the textures
    fl:SetTexture(textures.flash)
    --bu:SetHighlightTexture(textures.hover)
    bu:SetPushedTexture(textures.pushed)
    --bu:SetCheckedTexture(textures.checked)
    bu:SetNormalTexture(textures.normal)
    hooksecurefunc(bu, "SetNormalTexture", function(self, texture)
      --make sure the normaltexture stays the way we want it
      if texture and texture ~= textures.normal then
        self:SetNormalTexture(textures.normal)
      end
    end)
    --cut the default border of the icons and make them shiny
    ic:SetTexCoord(0.1,0.9,0.1,0.9)
  	ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
	  ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
    --shadows+background
    if not bu.bg then applyBackground(bu) end
    bu.rabs_styled = true
    end

--style stance buttons

  local function styleStanceButton(bu)
    if not bu or (bu and bu.rabs_styled) then return end
    local name = bu:GetName()
    local ic  = _G[name.."Icon"]
    local fl  = _G[name.."Flash"]
    local nt  = _G[name.."NormalTexture2"]
    nt:SetAllPoints(bu)
    --applying color
    nt:SetVertexColor(color.normal.r,color.normal.g,color.normal.b,1)
    --setting the textures
    fl:SetTexture(textures.flash)
    --bu:SetHighlightTexture(textures.hover)
    bu:SetPushedTexture(textures.pushed)
    --bu:SetCheckedTexture(textures.checked)
    bu:SetNormalTexture(textures.normal)
    --cut the default border of the icons and make them shiny
    ic:SetTexCoord(0.1,0.9,0.1,0.9)
    ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
    ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
    --shadows+background
    if not bu.bg then applyBackground(bu) end
    bu.rabs_styled = true
    end

--style possess buttons

  local function stylePossessButton(bu)
    if not bu or (bu and bu.rabs_styled) then return end
      local name = bu:GetName()
      local ic  = _G[name.."Icon"]
      local fl  = _G[name.."Flash"]
      local nt  = _G[name.."NormalTexture"]
      nt:SetAllPoints(bu)
      --applying color
      nt:SetVertexColor(color.normal.r,color.normal.g,color.normal.b,1)
      --setting the textures
      fl:SetTexture(textures.flash)
      --bu:SetHighlightTexture(textures.hover)
      bu:SetPushedTexture(textures.pushed)
      --bu:SetCheckedTexture(textures.checked)
      bu:SetNormalTexture(textures.normal)
      --cut the default border of the icons and make them shiny
      ic:SetTexCoord(0.1,0.9,0.1,0.9)
      ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
      ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
      --shadows+background
      if not bu.bg then applyBackground(bu) end
      bu.rabs_styled = true
  end

-- style bags

  local function styleBag(bu)
  	if not bu or (bu and bu.rabs_styled) then return end
	    local name = bu:GetName()
	    local ic  = _G[name.."IconTexture"]
	    local nt  = _G[name.."NormalTexture"]
	    nt:SetTexCoord(0,1,0,1)
	    nt:SetDrawLayer("BACKGROUND", -7)
	    nt:SetVertexColor(0.4, 0.35, 0.35)
	    nt:SetAllPoints(bu)
	    local bo = bu.IconBorder
	    bo:Hide()
	    bo.Show = function() end
	    ic:SetTexCoord(0.1,0.9,0.1,0.9)
      ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
      ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
  	  bu:SetNormalTexture(textures.normal)
	    --bu:SetHighlightTexture(textures.hover)
      bu:SetPushedTexture(textures.pushed)
      --bu:SetCheckedTexture(textures.checked)
 	
      --make sure the normaltexture stays the way we want it
  	  hooksecurefunc(bu, "SetNormalTexture", function(self, texture)
      if texture and texture ~= textures.normal then
        	self:SetNormalTexture(textures.normal)
      end
   	  end)
	    bu.Back = CreateFrame("Frame", nil, bu)
		  bu.Back:SetPoint("TOPLEFT", bu, "TOPLEFT", -4, 4)
		  bu.Back:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 4, -4)
		  bu.Back:SetFrameLevel(bu:GetFrameLevel() - 1)
		  bu.Back:SetBackdrop(backdrop)
      bu.Back:SetBackdropBorderColor(0, 0, 0, 0.9)
  end

--update hotkey func

  local function updateHotkey(self, actionButtonType)
    local ho = _G[self:GetName().."HotKey"]
    if ho and ho:IsShown() then
      ho:Hide()
    end
  end

  local function init()
    --style the actionbar buttons
    for i = 1, NUM_ACTIONBAR_BUTTONS do
      styleActionButton(_G["ActionButton"..i])
      styleActionButton(_G["MultiBarBottomLeftButton"..i])
      styleActionButton(_G["MultiBarBottomRightButton"..i])
      styleActionButton(_G["MultiBarRightButton"..i])
      styleActionButton(_G["MultiBarLeftButton"..i])
    end
	  --style bags
    for i = 0, 3 do
		styleBag(_G["CharacterBag"..i.."Slot"])
    end
	  styleBag(MainMenuBarBackpackButton)
    for i = 1, 6 do
      styleActionButton(_G["OverrideActionBarButton"..i])
    end
    --style leave button
	  styleLeaveButton(MainMenuBarVehicleLeaveButton)
    styleLeaveButton(rABS_LeaveVehicleButton)
    --petbar buttons
    for i=1, NUM_PET_ACTION_SLOTS do
      stylePetButton(_G["PetActionButton"..i])
    end
    --stancebar buttons
    for i=1, NUM_STANCE_SLOTS do
      styleStanceButton(_G["StanceButton"..i])
    end
    --possess buttons
    for i=1, NUM_POSSESS_SLOTS do
      stylePossessButton(_G["PossessButton"..i])
    end
    --extraactionbutton1
    styleExtraActionButton(ExtraActionButton1)
	  styleExtraActionButton(ZoneAbilityFrame.SpellButton)
    --spell flyout
    SpellFlyoutBackgroundEnd:SetTexture(nil)
    SpellFlyoutHorizontalBackground:SetTexture(nil)
    SpellFlyoutVerticalBackground:SetTexture(nil)
    local function checkForFlyoutButtons(self)
      local NUM_FLYOUT_BUTTONS = 10
      for i = 1, NUM_FLYOUT_BUTTONS do
        styleActionButton(_G["SpellFlyoutButton"..i])
      end
    end
    SpellFlyout:HookScript("OnShow",checkForFlyoutButtons)

    --dominos styling
    if dominos then
      --print("Dominos found")
      for i = 1, 60 do
        styleActionButton(_G["DominosActionButton"..i])
      end
    end
    --bartender4 styling
    if bartender4 then
      --print("Bartender4 found")
      for i = 1, 120 do
        styleActionButton(_G["BT4Button"..i])
		    stylePetButton(_G["BT4PetButton"..i])
      end
    end
  end

  local a = CreateFrame("Frame")
  a:RegisterEvent("PLAYER_LOGIN")
  a:SetScript("OnEvent", init)

  local animationsCount, animations = 5, {}
local animationNum = 1
local replace = string.gsub
local frame, texture, animationGroup, alpha1, scale1, scale2, rotation2

for i = 1, animationsCount do
  frame = CreateFrame("Frame")

  texture = frame:CreateTexture()
  texture:SetTexture([[Interface\Cooldown\star4]])
  texture:SetAlpha(0)
  texture:SetAllPoints()
  texture:SetBlendMode("ADD")
  animationGroup = texture:CreateAnimationGroup()

  alpha1 = animationGroup:CreateAnimation("Alpha")
  alpha1:SetFromAlpha(0)
  alpha1:SetToAlpha(1)
  alpha1:SetDuration(0)
  alpha1:SetOrder(1)

  scale1 = animationGroup:CreateAnimation("Scale")
  scale1:SetScale(1.5, 1.5)
  scale1:SetDuration(0)
  scale1:SetOrder(1)

  scale2 = animationGroup:CreateAnimation("Scale")
  scale2:SetScale(0, 0)
  scale2:SetDuration(0.3)
  scale2:SetOrder(2)

  rotation2 = animationGroup:CreateAnimation("Rotation")
  rotation2:SetDegrees(90)
  rotation2:SetDuration(0.3)
  rotation2:SetOrder(2)

  animations[i] = {frame = frame, animationGroup = animationGroup}
end

local animate = function(button)
  if not button:IsVisible() then
    return true
  end
  local animation = animations[animationNum]
  local frame = animation.frame
  local animationGroup = animation.animationGroup
  frame:SetFrameStrata("HIGH")
  --frame:SetFrameStrata(button:GetFrameStrata()) -- caused multiactionbars to show animation behind the bar instead of on top of it
  frame:SetFrameLevel(button:GetFrameLevel() + 10)
  frame:SetAllPoints(button)
  animationGroup:Stop()
  animationGroup:Play()
  animationNum = (animationNum % animationsCount) + 1
  return true
end

-- 'ActionButton_UpdateHotkeys' didn't run on PLAYER_ENTERING_WORLD, replaced with 'ActionButton_Update'
-- hooksecurefunc('ActionButton_Update', function(button, buttonType)
--   if InCombatLockdown() then return end -- no button flash while in CC, can be commented out, and animations will run while in CC
--   if not button.hooked then
--     local id, actionButtonType, key
--     if not actionButtonType then
--       -- button:GetAttribute('binding') is always nil, it's a waste to run, so it's short-circuited (start working in coming patches)
--       actionButtonType =  string.upper(button:GetName()) or button:GetAttribute('binding')

--       actionButtonType = replace(actionButtonType, 'BOTTOMLEFT', '1')
--       actionButtonType = replace(actionButtonType, 'BOTTOMRIGHT', '2')
--       actionButtonType = replace(actionButtonType, 'RIGHT', '3')
--       actionButtonType = replace(actionButtonType, 'LEFT', '4')
--       actionButtonType = replace(actionButtonType, 'MULTIBAR', 'MULTIACTIONBAR')
--     end
--     local key = GetBindingKey(actionButtonType)
--     if key then
--       button:RegisterForClicks("AnyDown")
--       SetOverrideBinding(button, true, key, 'CLICK '..button:GetName()..':LeftButton')
--     end
--     button.AnimateThis = animate
--     SecureHandlerWrapScript(button, "OnClick", button, [[ control:CallMethod("AnimateThis", self) ]])
--     button.hooked = true  
--   end
-- end)
