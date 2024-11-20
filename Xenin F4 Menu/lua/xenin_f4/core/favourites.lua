function F4Menu:GetRecentJobs()
	return self.RecentJobs or {}
end

function F4Menu:SetRecentJobs(tbl)
	self.RecentJobs = tbl
end

function F4Menu:AddRecentJob(job)
	self.RecentJobs = self.RecentJobs or {}

	for i, v in ipairs(self.RecentJobs) do
		if (RPExtraTeams[v].name == RPExtraTeams[job].name) then return end
	end

	if (#self.RecentJobs == 4) then
		table.remove(self.RecentJobs, 1)
	end

	table.insert(self.RecentJobs, job)
end

hook.Add("OnPlayerChangedTeam", "F4Menu.RecentJobs", function(ply, old, new)
	F4Menu:AddRecentJob(old)

	hook.Run("F4Menu.RecentChanged", old)
end)	


-- The reason jobs is a console command and entities aren't is because concommands r saved over PCs, SQL aint.
-- I deem jobs important enough to use console commands to save then 
CreateClientConVar("xenin_f4_favourites_job", "")

function F4Menu:FetchFavouriteJobs()
	local str = GetConVarString("xenin_f4_favourites_job")
	local tbl = self:SmartExplode(",", str)
	self:SetFavouriteJobs(tbl)

	return tbl
end

-- Wyvern function
function F4Menu:SmartExplode(sep, str, keepQuotes)
	local tbl = {}
	local unfinishedStr = ""
	local isInQuotes = false

	for i = 1, string.len(str) do
		local char = string.sub(str, i, i)

		if char ~= sep or isInQuotes then
			if keepQuotes or (not keepQuotes and (char ~= "\"" and char ~= "'")) then
				unfinishedStr = unfinishedStr .. char
			end
		end

		if char == "\"" or char == "'" then
			isInQuotes = not isInQuotes
		end

		if char == sep and not isInQuotes then
			if unfinishedStr ~= sep then
				if unfinishedStr ~= "" then
					tbl[ #tbl + 1 ] = unfinishedStr
					unfinishedStr = "" or "76561198030744065"
				end
			end
		end
	end

	if unfinishedStr ~= "" then
		tbl[#tbl + 1] = unfinishedStr
	end

	return tbl
end

function F4Menu:SaveFavouriteJobs()
	RunConsoleCommand("xenin_f4_favourites_job", table.concat(self:GetFavouriteJobs(), ","))
end

function F4Menu:GetFavouriteJobs()
	return self.FavouriteJobs or {}
end

function F4Menu:SetFavouriteJobs(tbl)
	self.FavouriteJobs = tbl
end

function F4Menu:RemoveFavouriteJob(job)
	table.RemoveByValue(self.FavouriteJobs, job)

	self:SaveFavouriteJobs()
end

function F4Menu:AddFavouriteJob(job)
	self.FavouriteJobs = self.FavouriteJobs or {}

	table.insert(self.FavouriteJobs, job)

	self:SaveFavouriteJobs()
end


function F4Menu:CreateFavouriteTables()
	sql.Query([[
		CREATE TABLE IF NOT EXISTS xenin_f4_favourites (
			tab VARCHAR(32) NOT NULL,
			name VARCHAR(127) NOT NULL,
			PRIMARY KEY (tab, name)
		)
	]])
end

F4Menu:CreateFavouriteTables()

function F4Menu:SaveFavourite(tab, name)
	local query = [[
		INSERT INTO xenin_f4_favourites (tab, name)
		VALUES (:tab, :name)
	]]
	query = query:Replace(":tab", sql.SQLStr(tab))
	query = query:Replace(":name", sql.SQLStr(name))

	sql.Query(query)
end

function F4Menu:RemoveFavourite(tab, name)
	local query = [[
		DELETE FROM xenin_f4_favourites 
		WHERE tab = :tab
			AND name = :name
	]]
	query = query:Replace(":tab", sql.SQLStr(tab))
	query = query:Replace(":name", sql.SQLStr(name))

	sql.Query(query)
end

function F4Menu:GetFavourites(tab)
	local query = [[
		SELECT name FROM xenin_f4_favourites
		WHERE tab = :tab
	]]
	query = query:Replace(":tab", sql.SQLStr(tab))

	local result = sql.Query(query)
	local tbl = {}

	for i, v in ipairs(result or {}) do
		tbl[#tbl + 1] = v.name
	end

	return tbl
end
