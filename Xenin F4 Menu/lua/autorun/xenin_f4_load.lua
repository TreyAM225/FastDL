F4Menu = F4Menu or {}
F4Menu.OfflinePlayersMoney = F4Menu.OfflinePlayersMoney or 0
F4Menu.EconomySnapshot = F4Menu.EconomySnapshot or {}

function F4Menu:IncludeClient(path)
	if (CLIENT) then
		include("xenin_f4/" .. path .. ".lua")
	end

	if (SERVER) then
		AddCSLuaFile("xenin_f4/" .. path .. ".lua")
	end
end

function F4Menu:IncludeServer(path)
	if (SERVER) then
		include("xenin_f4/" .. path .. ".lua")
	end
end

function F4Menu:IncludeShared(path)
	self:IncludeServer(path)
	self:IncludeClient(path)
end

local function Load()
	-- Initialise the config wrapper
	F4Menu:IncludeShared("core/config_wrapper")

	-- Config
	F4Menu:IncludeShared("configuration/commands")
	F4Menu:IncludeShared("configuration/config")
	
	-- Core non UI aspects of the F4 menu
	F4Menu:IncludeClient("core/favourites")
	F4Menu:IncludeShared("core/item_limit")
	F4Menu:IncludeClient("core/darkrp")

	-- Responsible for server client communication & persistent storage
	F4Menu:IncludeServer("data/database")
	F4Menu:IncludeClient("data/network_client")
	F4Menu:IncludeServer("data/network_server")
	
	-- Frame main
	F4Menu:IncludeClient("ui/frame/main")
	F4Menu:IncludeClient("ui/frame/player")
	F4Menu:IncludeClient("ui/frame/commands")
	-- Jobs
	F4Menu:IncludeClient("ui/jobs/main")
	F4Menu:IncludeClient("ui/jobs/row")
	F4Menu:IncludeClient("ui/jobs/slideout")
	F4Menu:IncludeClient("ui/jobs/slideout_desc")
	F4Menu:IncludeClient("ui/jobs/slideout_weapons")
	F4Menu:IncludeClient("ui/jobs/slideout_ranks")
	
	-- Dashboard
	F4Menu:IncludeClient("ui/dashboard/main")
	F4Menu:IncludeClient("ui/dashboard/navbar")
	F4Menu:IncludeClient("ui/dashboard/stats_general")
	F4Menu:IncludeClient("ui/dashboard/stats_graph")
	F4Menu:IncludeClient("ui/dashboard/staff")

	-- Base content
	F4Menu:IncludeClient("ui/items/base/base")
	F4Menu:IncludeClient("ui/items/base/main")
	F4Menu:IncludeClient("ui/items/base/row")

	-- Items
	F4Menu:IncludeClient("ui/items/entities")
	F4Menu:IncludeClient("ui/items/weapons")
	F4Menu:IncludeClient("ui/items/vehicles")
	F4Menu:IncludeClient("ui/items/shipments")
	F4Menu:IncludeClient("ui/items/food")
	F4Menu:IncludeClient("ui/items/ammo")
	
	-- Misc
	F4Menu:IncludeClient("ui/misc/html")
	F4Menu:IncludeClient("ui/misc/url")

	F4Menu.FinishedLoading = true
end

if (XeninUI) then
	Load()
else
	--
	hook.Add("XeninUI.Loaded", "F4Menu", function()
		Load()
	end)
end

if (SERVER) then
	-- XeninUI
	resource.AddWorkshop("1900562881")
	-- F4 content
	resource.AddWorkshop("1956177393")
end