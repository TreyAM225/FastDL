-- Initialise config
local cfg = F4Menu:CreateConfig()

/*
	Set the language!
	You can find the languages you can use here: https://gitlab.com/sleeppyy/xenin-languages/tree/master/f4menu
	You don't need to write the .json part

	If you want to add your own language you can
	1. Create a pull request (create new file) that will be uploaded to that website with the language
	2. Use a second argument in the :SetLanguage function

	How to do now #2. This will set the language without needing to use the version from a website. 
	cfg:SetLanguage("french", [[
		{
			"phrases": {
				"dashboard": {
					
				}
			}
		}
	]])

	So for example
	cfg:SetLanguage("russian", [[
		-- copy the contents of english.json and translate it here
	]])

	It's recommended you use method #1, but you can use method #2 till the file you upload have been approved
*/
cfg:SetLanguage("english")

-- Set the title of the F4
-- This can be a string, i.e. "Xenin F4"
-- Or it can be a function
-- i.e. function() return "Xenin F4 - " .. LocalPlayer():getDarkRPVar("money") end
-- A function will refresh every 10 seconds, so you can have things that change
cfg:SetTitle("TripRP")

-- Lets set the amount of columns per row for jobs & items
cfg:SetColumnsPerRow(2)

-- Should the menu close after changing job?
cfg:SetCloseMenuAfterJobChange(false)

-- Default sequence for jobs in the slideout menu?
-- Set to false if you want to disable
cfg:SetDefaultJobSequence("pose_standing_02")

-- Should models be rendered in real time? 
-- If you have a ton of things in your F4 I recommend you changing this to false, it helps with performance a lot
-- It does look worse, and not every model might have an icon (it's the models fault)
cfg:SetRealtimeModelsEnabled(true)

-- Should weapons use the addon Easy Skins to skin weapons if you have any equipped?
cfg:SetEasySkins(true)

-- How long should it take between typing the last letter of a search to it happens
-- This is so it doesn't constantly update & lags while you search for something
cfg:SetDebounceLength(0.2)

-- Empty the search bar when you switch tabs in the items menu?
cfg:SetEmptySearchOnTabSwitch(true)

-- Should categories start expanded?
cfg:SetCategoriesStartExpanded(true)

-- Should the category color be the color of the category box?
-- Example of how true looks: https://i.imgur.com/VB5rHXd.png
cfg:SetCategoriesBackgroundFullyColored(false)

-- Should "Total Money" circle in the dashboard also count people that's offline?
cfg:SetUseOfflineMoney(true)

-- For the total money.
cfg:SetMoneyConfig({
	-- How often should it cache the total amount of money?
	-- This is in seconds
	CacheInterval = 120,
	-- Only count active players money
	-- Set to false to disable, and any number to determine the amount of days since last login to count as active
	DaysSinceLastLogin = 14
})

-- Setup the order of how tabs should be in the items menu
cfg:SetItemsOrder({
	"Entities", "Weapons", "Shipments", "Ammo", "Vehicles", "Food"
})

-- The sidebar colors. These are gradients. The first part is the start color, the second is the end color
cfg:SetSidebarColors({
	Player = { Color(208, 62, 106), Color(200, 60, 123) },
	PlayerAvatar = { Color(251, 211, 50), Color(69, 198, 103) },
	Commands = { Color(200, 60, 123), Color(176, 55, 180) },
})

-- You can change the colours of the menu slightly.
-- The defaults values you can just replace with Color(r, g, b), it will work
cfg:SetColors({
	Top = XeninUI.Theme.Primary,
	Sidebar = XeninUI.Theme.Primary,
	Background = XeninUI.Theme.Background
})

-- Add staff
-- :AddStaff(usergroup, display_name, color [optional])
cfg:AddStaff("superadmin", "Super Admin", XeninUI.Theme.Blue)

-- Set the tab that'll it will open up on when you open the menu first time
cfg:SetActiveTab("Dashboard")

-- Set the resolution of the addon
-- width, height
-- If the resolution is higher than a users resolution it will be scaled down to 100% of the users resolution.
-- So if you set it to 1920x1080, but a user got 1280x720 resolution it will be 1280x720.
-- You can set this to 9999, 9999 and it'll be fullscreen no matter what
--
-- This can also be a function!
-- If it's a function it HAS to return a fraction (0-1)
-- 1 = fullscreen
-- 0 = nothing
-- Please be aware that the smallest it can go is 960x600. This is due to a lack of pixels, it simply doesn't have space to draw anything.
--
-- Example function: 
-- This is equal to the default aspect ratio that 1280x750 pixels provide on 1080p
-- cfg:SetResolution(function()
-- 	return 0.67, 0.7
-- end)
--
cfg:SetResolution(1280, 750)

-- Add custom commands easily. 
-- Advanced custom commands beyond just a simple chat command can be added in commands.lua with Lua knowledge
-- Commands are not translated, so you can type what you want.

-- If you want to you can create a custom category.
------
-- cfg:AddCategory("My Category")
------

-- Add a command
-- The first parameter is the name of the category it belongs to. Check commands.lua for default categories names
-- The second parameter is the text shown in the menu
-- The third parameter is the chat message you make the player say.
------
-- cfg:AddCommand("options.general.name", "Say Hi", "/ooc hi")
------

--------------------------
-- The sidebar content  --
--------------------------

-- Add a divider from the top player part
cfg:AddDivider()

-- Add the first tab
-- name = the display name of the tab
-- desc = the description
-- panel = the Lua VGUI panel. This can be used for custom tabs easily if the addon uses vgui.Register for UI
-- icon is optional, if you don't want an icon just remove the field
-- if you want an icon it uses imgur id, so if you want "https://i.imgur.com/0HYmtUy.png" you will need to set icon to "0HYmtUy"
cfg:AddTab({
	name = "Dashboard",
	desc = "Server stats & more",
	panel = "F4Menu.Dashboard",
	-- If your server/players are Turkish, you need to set it up differently as Imgur is blocked in Turkey
	-- You can set it up as a table with different URLs.
	-- An example for Imgur + non Imgur fallback
	--	{ 
	--		If you don't setup any URL it'll use imgur. If you don't setup any type it'll use png. You can use png/jpg
	--		{ id = "Tpm965d" },
	--		{ id = "va1Y1D", url = "https://hizliresim.com", type = "png" }
	--	}
	icon = "Tpm965d"
})
cfg:AddTab({
	name = "Jobs",
	desc = "Get a career!",
	panel = "F4Menu.Jobs",
	icon = "MsBaa8Y"
})
cfg:AddTab({
	name = "Items",
	desc = "Entities & more",
	panel = "F4Menu.Items",
	icon = "HVnAVBY"
})

--[[
-- You can have URLs
-- It will try to open the URL in the Steam Browser upon pressing the tab.
cfg:AddURL({
	name = "Donate",
	desc = "Give me shekels",
	-- Used to display title once you have pressed on the tab.
	tabName = "Donation Shop",
	url = "https://store.xeningaming.com"
})

-- You can also add a website that'll be shown in the F4 menu itself instead of Steam Browser
-- You don't need a tab name here.
cfg:AddWebsite({
	name = "Donate website",
	desc = "Give me shekels",
	url = "https://store.xeningaming.com"
})
--]]

-- If you have Xenin Inventory you can set enabled to true
-- You don't need panel for these
cfg:SetXeninInventory({
	enabled = false,
	name = "Inventory",
	desc = "Store your things",
	icon = "iCAiL7W"
})

-- If you have Xenin Battle Pass you can set enabled to true
-- Requires Battle Pass 1.0.7a or higher!
cfg:SetXeninBattlePass({
	enabled = false,
	name = "Battle Pass",
	desc = "Rewards & challenges",
	icon = "hnalpdT"
})

-- If you have Xenin Coinflips you can set this to true
-- At least version 1.0.8b
cfg:SetXeninCoinflips({
	enabled = false,
	name = "Coinflips",
	desc = "Flip a coin",
	icon = "C3MyKJE"
})

cfg:AddDivider()
cfg:AddWebsite({
	name = "Discord",
	desc = "Join our Discord",
	url = "https://discord.gg/GuXWEmN",
	icon = "vHESvbx"
})
cfg:AddWebsite({
	name = "Steam Group",
	desc = "Join our group",
	url = "https://steamcommunity.com/id/randomiddududu",
	icon = "jvjxAQK"
})