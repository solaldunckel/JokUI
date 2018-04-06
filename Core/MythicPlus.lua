local _, JokUI = ...
local MythicPlus = JokUI:RegisterModule("Mythic +")

local features = {}

local mythicplus_defaults = {
    profile = {        
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
        order = 10,
        args = {
	        nameplateProgress = {
				type = "toggle",
				name = "Show Progress on Nameplates",
				width = "full",
				desc = "|cffaaaaaa Adds percentage progress on Nameplates |r",
		        descStyle = "inline",
				order = 2,
				set = function(info,val) JokUIDB.enableNameplateText = val
				Nameplates:ForceUpdate()
				end,
				get = function(info) return JokUIDB.enableNameplateText end
			},
			currentPull = {
				type = "toggle",
				name = "Show Current Pull Progress",
				width = "full",
				desc = "|cffaaaaaa Show a frame displaying current pull's progress |r",
		        descStyle = "inline",
				order = 3,
				set = function(info,val) JokUIDB.enablePullEstimate = val
				end,
				get = function(info) return JokUIDB.enablePullEstimate end
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
}

function MythicPlus:OnInitialize()
    self.db = JokUI.db:RegisterNamespace("Mythic +", mythicplus_defaults)
    self.settings = self.db.profile
    JokUI.Config:Register("Mythic +", mythicplus_config, 13)
end

function MythicPlus:OnEnable()
	for name in pairs(features) do
		self:SyncFeature(name)
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
				MythicPlus:SyncFeature(name)
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