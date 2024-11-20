local PANEL = {}

XeninUI:CreateFont("F4Menu.Dashboard.Stats.Circle.Title", 18)
XeninUI:CreateFont("F4Menu.Dashboard.Stats.Circle", 24)

function PANEL:Init()
	net.Start("F4Menu.OfflinePlayersMoney")
	net.SendToServer()

	self.Stats = {}

	self:CreateStat(F4Menu:GetPhrase("dashboard.tabs.general.online.title"), XeninUI.Theme.Blue, function()
		return player.GetCount() / game.MaxPlayers()
	end, function()
		return F4Menu:GetPhrase("dashboard.tabs.general.online.data", {
			online = player.GetCount(),
			max = game.MaxPlayers()
		})
	end)
	self:CreateStat(F4Menu:GetPhrase("dashboard.tabs.general.totalMoney.title"), XeninUI.Theme.Green, nil, function()
		local money = tonumber(F4Menu.OfflinePlayersMoney) or 0
		if (!F4Menu.Config.UseOfflineMoney) then
			money = 0
		end
		for i, v in ipairs(player.GetAll()) do
			money = money + (v:getDarkRPVar("money") or 0)
		end


		if (money >= 10 ^ 12) then
			return DarkRP.formatMoney(math.Round(money / (10 ^ 12), 2)) .. "T"
		elseif (money >= 10 ^ 9) then
			return DarkRP.formatMoney(math.Round(money / (10 ^ 9), 2)) .. "B"
		elseif (money >= 10 ^ 6) then
			return DarkRP.formatMoney(math.Round(money / (10 ^ 6), 2)) .. "M"
		elseif (money >= 10 ^ 3) then
			return DarkRP.formatMoney(math.Round(money / (10 ^ 3), 2)) .. "K"
		end

		return DarkRP.formatMoney(money)
	end)
	self:CreateStat(F4Menu:GetPhrase("dashboard.tabs.general.jobDistribution.title"), nil, nil)

	local richestPlayer = F4Menu.RichestPlayer
	if (richestPlayer) then
		self:AddPlayer(richestPlayer)
	else
		net.Start("F4Menu.RichestPlayer")
		net.SendToServer()
	end

	self:AddHook("F4Menu.RichestPlayer", "F4Menu.Stats.General", function(self, richestPlayer)
		self:AddPlayer(richestPlayer)
	end)
end

function PANEL:CreateStat(stat, color, func, value)
	color = color or XeninUI.Theme.Red
	func = func or function() return 1 end
	value = value or function() return "" end

	local panel = self:Add("DPanel")
	panel:Dock(LEFT)
	panel.CalculatePolygons = function(pnl, w, h)
		pnl.InnerCircle = XeninUI:CalculateCircle(w / 2, h / 2, h / 2 - 30, 45)
		pnl.OuterCircle = XeninUI:CalculateCircle(w / 2, h / 2, h / 2 - 10, 45)
	end
	panel.Paint = function(pnl, w, h)
		XeninUI:MaskInverse(function()
			XeninUI:DrawCachedCircle(pnl.InnerCircle, color_white)
		end, function()
			XeninUI:DrawCachedCircle(pnl.OuterCircle, XeninUI.Theme.Primary)
		end)

		local frac = func()

		if (stat == F4Menu:GetPhrase("dashboard.tabs.general.jobDistribution.title")) then
			local ang = 0
			local playerCount = player.GetCount()
			local jobs = {}
			for i, v in ipairs(RPExtraTeams) do
				local amt = team.NumPlayers(v.team)

				if (amt > 0) then
					table.insert(jobs, {
						team = v.team,
						col = team.GetColor(v.team),
						amt = amt,
					})
				end
			end
			
			-- TODO Should add arc caching
			for i, v in ipairs(jobs) do
				local frac = v.amt / playerCount
				local angles = frac * 360
				XeninUI:DrawArc(w / 2, h / 2, ang, angles, h / 2 - 30, ColorAlpha(v.col, 100), 45)
				XeninUI:MaskInverse(function()
					XeninUI:DrawCachedCircle(pnl.InnerCircle, color_white)
				end, function()
					XeninUI:DrawArc(w / 2, h / 2, ang, angles, h / 2 - 10, v.col, 45)
				end)

				ang = ang + angles
			end
		else
			XeninUI:DrawArc(w / 2, h / 2, 0, frac * 360, h / 2 - 30, ColorAlpha(color, 100), 45)
			XeninUI:MaskInverse(function()
				XeninUI:DrawCachedCircle(pnl.InnerCircle, color_white)
			end, function()
				XeninUI:DrawArc(w / 2, h / 2, 0, frac * 360, h / 2 - 10, color, 45)
			end)
		end
		
		local val = value()
		XeninUI:DrawShadowText(stat, "F4Menu.Dashboard.Stats.Circle.Title", w / 2, h / 2, Color(215, 215, 215), TEXT_ALIGN_CENTER, val == "" and TEXT_ALIGN_CENTER or TEXT_ALIGN_BOTTOM, 1, 150)
		if (val != "") then
			XeninUI:DrawShadowText(val, "F4Menu.Dashboard.Stats.Circle", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, 150)
		end
	end
	panel.PerformLayout = function(pnl, w, h)
		pnl:CalculatePolygons(w, h)
	end

	table.insert(self.Stats, panel)
end

XeninUI:CreateFont("F4Menu.Dashboard.Stats.Player.Title", 24)
XeninUI:CreateFont("F4Menu.Dashboard.Stats.Player", 20)
XeninUI:CreateFont("F4Menu.Dashboard.Stats.Player.Money", 16)
XeninUI:CreateFont("F4Menu.Dashboard.Stats.Player.Percentage", 12)

function PANEL:AddPlayer(tbl)
	local sid64 = tbl.sid64
	local ply = player.GetBySteamID64(sid64)
	local name = ply and ply:Nick() or tbl.name
	local money = ply and (ply:getDarkRPVar("money") or tbl.money) or tbl.money or 0

	local panel = self:Add("Panel")
	panel:Dock(LEFT)
	panel.Avatar = panel:Add("XeninUI.Avatar")
	panel.Avatar.avatar:SetSteamID(sid64, 128)
	panel.Avatar:SetVertices(90)
	panel.Avatar.CalculateMoney = function(pnl)
		local money = tonumber(F4Menu.OfflinePlayersMoney) or 0
		for i, v in ipairs(player.GetAll()) do
			if (!v:getDarkRPVar("money")) then continue end
			
			money = money + (v:getDarkRPVar("money") or 0)
		end

		return money
	end
	panel.Avatar.avatar.CalculatePolygons = function(pnl, w, h)
		pnl.Circle = XeninUI:CalculateCircle(h / 2 - 1, h / 2, h / 2 + 1, 45)
	end
	panel.Avatar.avatar.PaintOver = function(pnl, w, h)
		pnl:NoClipping(false)
			XeninUI:DrawCachedCircle(pnl.Circle, Color(0, 0, 0, 225))
		pnl:NoClipping(true)

		XeninUI:DrawShadowText(F4Menu:GetPhrase("dashboard.tabs.general.richestPlayer.title"), "F4Menu.Dashboard.Stats.Player.Title", w / 2, h / 2 - 8, Color(160, 160, 160), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, 255)
		XeninUI:DrawShadowText(name, "F4Menu.Dashboard.Stats.Player", w / 2, h / 2 - 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, 255)
		XeninUI:DrawShadowText(DarkRP.formatMoney(money), "F4Menu.Dashboard.Stats.Player.Money", w / 2, h / 2 + 16, XeninUI.Theme.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, 255)

		local frac = math.Clamp(money / panel.Avatar:CalculateMoney(), 0, 1)
		XeninUI:DrawShadowText(F4Menu:GetPhrase("dashboard.tabs.general.richestPlayer.economy", { percentage = math.Round(frac * 100, 2) }), "F4Menu.Dashboard.Stats.Player.Percentage", w / 2, h - 32, Color(185, 185, 185), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, 255)
	end
	
	panel.PerformLayout = function(pnl, w, h)
		local size = h - 10

		panel.Avatar:SetPos(w - size - 20, h - size)
		panel.Avatar:SetSize(size, size - 10)
		panel.Avatar.avatar:CalculatePolygons(w, h)
	end

	table.insert(self.Stats, panel)
end

function PANEL:PerformLayout(w, h)
	for i, v in ipairs(self.Stats) do
		v:SetWide(w * 0.25)
		v:DockMargin(0, 0, 0, 0)
	end
end

vgui.Register("F4Menu.Dashboard.Stats.General", PANEL)