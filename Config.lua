local _, JokUI = ...
local Config = JokUI:RegisterModule("Config")

local AceConfig = LibStub("AceConfig-3.0")

if (IsAddOnLoaded("MoveAnything")) then
	IsMoveAnythingLoaded = " |cffffd100/jokmove : |r" 
else
	IsMoveAnythingLoaded = " |cffffd100/move : |r"
end

local options = {
	type = "group",
	args = {
		About = {
			name = "About",
			order = 1,
			type = "group",
			args = {
				title = {
					type = "description",
					name = "|cff64b4ffJokUI",
					fontSize = "large",
					order = 0
				},
				desc = {
					type = "description",
					name = "Interface, Nameplates, Raid Frames and various useful options.",
					fontSize = "medium",
					order = 1
				},
				author = {
					type = "description",
					name = "\n|cffffd100Author: |r Kygo @ EU-Hyjal",
					order = 2
				},
				version = {
					type = "description",
					name = "|cffffd100Version: |r" .. GetAddOnMetadata("JokUI", "Version"),
					order = 3
				},
				command = {
					type = "description",
					name = "\n|cffffd100  Commandes :|r",
					fontSize = "large",
					order = 4
				},
				command1 = {
					type = "description",
					name = " |cffffd100/hb : |r Open the 'hoverbind' configuration.",
					fontSize = "medium",
					order = 5
				},
				command2 = {
					type = "description",
					name = " |cffffd100/sgrid 64 : |r Show a grid on your screen.",
					fontSize = "medium",
					order = 6
				},
				command3 = {
					type = "description",
					name = IsMoveAnythingLoaded.." Move and preview boss frames, player power bar and extra action button.",
					fontSize = "medium",
					order = 8
				},
			}
		}
	}
}

function Config:OnInitialize()
	AceConfig:RegisterOptionsTable("JokUI", options)
end

function Config:OnEnable()
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(JokUI.db)
end

function Config:Register(title, config, order)
	if order == nil then order = 10 end
	options.args[title] = {
		name = title,
		order = order,
		type = "group",
		args = config
	}
end