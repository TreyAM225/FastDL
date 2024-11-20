local PANEL = {}

XeninUI:CreateFont("F4Menu.Jobs.Slideout.Job", 30)
XeninUI:CreateFont("F4Menu.Jobs.Slideout.Level", 20)
XeninUI:CreateFont("F4Menu.Jobs.Slideout.CustomCheck", 18)
XeninUI:CreateFont("F4Menu.Jobs.Slideout.Donator", 20)
XeninUI:CreateFont("F4Menu.Jobs.Slideout.Tab", 14)
XeninUI:CreateFont("F4Menu.Jobs.Slideout.Bottom.Salary", 24)
XeninUI:CreateFont("F4Menu.Jobs.Slideout.Bottom.SalarySmall", 15)
XeninUI:CreateFont("F4Menu.Jobs.Slideout.Bottom.Action", 18)

local matGradient = Material("gui/gradient_down")

function PANEL:Init()
	self.Info = self:Add("DPanel")
	self.Info.Paint = function(pnl, w, h)
		XeninUI:DrawRoundedBox(0, 0, 0, w, h, XeninUI.Theme.Navbar)

		surface.SetMaterial(matGradient)
		surface.SetDrawColor(ColorAlpha(self.Job.color, 50))
		surface.DrawTexturedRect(0, 0, w, h * 0.3)
	end
	self.Info:Dock(LEFT)
	self.Info:DockPadding(16, 16, 16, 16)

	self.Info.Content = self:Add("Panel")

	self.Tabs = self.Info:Add("XeninUI.Navbar")
	self.Tabs.accent = XeninUI.Theme.Purple
	self.Tabs.textActive = color_white
	self.Tabs.font = "F4Menu.Jobs.Slideout.Tab"
	self.Tabs.minSize = 0
	self.Tabs.padding = 25
	self.Tabs.startHeight = 36
	self.Tabs.lineBasedOffText = true
	self.Tabs.dockLeft = 24 - (self.Tabs.padding / 2)
	self.Tabs.animation = "none"
	self.Tabs.Paint = function(pnl, w, h)
		surface.SetDrawColor(XeninUI.Theme.Primary)
		surface.DrawRect(0, h - 2, w, 2)
	end
	self.Tabs:SetBody(self.Info.Content)
	self.Tabs:AddTab(F4Menu:GetPhrase("jobs.slideout.tabs.description"), "F4Menu.Jobs.Slideout.Desc")
	self.Tabs:SetActive(F4Menu:GetPhrase("jobs.slideout.tabs.description"))

	self.Bottom = self.Info:Add("DPanel")
	self.Bottom:Dock(BOTTOM)
	self.Bottom:DockMargin(-16, -16, -16, -16)
	self.Bottom.Paint = function(pnl, w, h)
		surface.SetDrawColor(XeninUI.Theme.Primary)
		surface.DrawRect(0, 0, w, 2)

		local salary = self.Job.salary
		local str = DarkRP.formatMoney(salary)
		XeninUI:DrawShadowText(str, "F4Menu.Jobs.Slideout.Bottom.Salary", 24, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, 125)
		surface.SetFont("F4Menu.Jobs.Slideout.Bottom.Salary")
		local tw, th = surface.GetTextSize(str)
		XeninUI:DrawShadowText(F4Menu:GetPhrase("jobs.slideout.anHour"), "F4Menu.Jobs.Slideout.Bottom.SalarySmall", 24 + tw + 1, h / 2, Color(182, 182, 182), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, 125) 
	end

	self.Bottom.Action = self.Bottom:Add("DButton")
	self.Bottom.Action:SetText("BECOME")
	self.Bottom.Action:SetFont("F4Menu.Jobs.Slideout.Bottom.Action")
	self.Bottom.Action:SetTextColor(color_black)
	self.Bottom.Action.Color = Color(255, 153, 72)
	self.Bottom.Action.CanChange = true
	self.Bottom.Action.Paint = function(pnl, w, h)
		XeninUI:DrawRoundedBox(6, 0, 0, w, h, pnl.Color)
	end
	self.Bottom.Action.DoClick = function(pnl)
		if (!pnl.CanChange) then return end
		
		local job = self.Job
		if (!job) then return end

		if (job.vote or job.RequiresVote and job.RequiresVote(LocalPlayer(), job.team)) then
			RunConsoleCommand("darkrp", "vote" .. job.command)
		else
			RunConsoleCommand("darkrp", job.command)
		end

		if (F4Menu.Config.CloseMenuAfterJobChange) then
			if (IsValid(F4Menu.Frame)) then
				F4Menu.Frame:SetVisible(false)

				return
			end
		end

		hook.Run("F4Menu.CloseMenu", self.Dashboard)
	end

	self.Model = self:Add("DModelPanel")
	self.Model:Dock(FILL)
	self.Model.LayoutEntity = function() end
	self.Model.Models = {}
	self.Model.ClearModels = function(pnl)
		for i, v in pairs(pnl.Models) do
			v:Remove()
		end

		pnl.Models = {}
	end
	self.Model.SetModels = function(pnl, tbl)
		if (!istable(tbl)) then return end
		if (#tbl == 1) then return end

		for i, v in ipairs(tbl) do
			panel = pnl:Add("DModelPanel")
			panel:SetCamPos(Vector(20, 0, 65))
			panel:SetLookAt(Vector(0, 0, 65))
			panel:SetFOV(78)
			panel:SetModel(v)
			panel.LayoutEntity = function() end
			local basePaint = baseclass.Get("DModelPanel").Paint
			panel.Color = XeninUI.Theme.Navbar
			panel.Paint = function(pnl, w, h)
				XeninUI:DrawCircle(h / 2, h / 2, h / 2 - 4, 45, ColorAlpha(XeninUI.Theme.Navbar, 100))

				XeninUI:Mask(function()
					XeninUI:DrawCircle(h / 2, h / 2, h / 2 - 4, 45, XeninUI.Theme.Navbar)
				end, function()
					basePaint(pnl, w, h)
				end)

				XeninUI:MaskInverse(function()
					XeninUI:DrawCircle(h / 2, h / 2, h / 2 - 4 - 1, 45, color_white)
				end, function()
					XeninUI:DrawCircle(h / 2, h / 2, h / 2 - 4, 45, pnl.Color)
				end)
			end
			panel:AddHook("F4Menu.Jobs.Slideout.ChangedModel", "Model." .. i, function(pnl, model)
				if (pnl:GetModel() != model) then
					pnl:LerpColor("Color", XeninUI.Theme.Navbar)
				end
			end)
			panel.DoClick = function(pnl)
				self:SetModel(pnl:GetModel())
				self.ActiveModel = pnl:GetModel()
				DarkRP.setPreferredJobModel(self.Job.team, pnl:GetModel())

				hook.Run("F4Menu.Jobs.Slideout.ChangedModel", pnl:GetModel())
			end
			panel.OnCursorEntered = function(pnl)
				pnl:LerpColor("Color", XeninUI.Theme.Green)

				self:SetModel(pnl:GetModel())
			end
			panel.OnCursorExited = function(pnl)
				if (self.ActiveModel == pnl:GetModel()) then
					return 
				else
					self:SetModel(self.ActiveModel)
				end

				pnl:LerpColor("Color", XeninUI.Theme.Navbar)
			end
			if (i == 1) then
				panel.Color = XeninUI.Theme.Green
				panel:DoClick()
			end

			table.insert(pnl.Models, panel)
		end
	end
	self.Model.PerformLayout = function(pnl, w, h)
		pnl.BaseClass.PerformLayout(pnl, w, h)

		local y = 16
		local size = 40
		local x = 16 + size
		for i, v in ipairs(pnl.Models) do
			v:SetSize(size, size)
			v:AlignRight(x)
			v:AlignTop(y)

			if (i % 2 == 0) then
				x = 16 + size
				y = y + size
			else
				x = 16
			end
		end
	end
end

function PANEL:SetModel(mdl)
	if (IsValid(self.Model.Entity)) then
		if (IsValid(self.Model.Entity.Wep)) then
			self.Model.Entity.Wep:Remove()
		end
	end
	self.Model.OnRemove = function(pnl)
		if (IsValid(pnl.Entity.Wep)) then
			pnl.Entity.Wep:Remove()
		end
	end
	self.Model.PostDrawModel = function(pnl)
		if (IsValid(pnl.Entity.Wep)) then
			pnl.Entity.Wep:DrawModel()
		end
	end
	self.Model:SetModel(mdl)
	if (IsValid(self.Model.Entity)) then
		local mn, mx = self.Model.Entity:GetRenderBounds()
		local size = 0
		size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
		size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
		size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
		self.Model:SetFOV(32)
		self.Model:SetCamPos(Vector(size, size - 75, size - 25))
		self.Model:SetLookAt((mn + mx) * 0.5)
		self.Model.Entity:SetPos(Vector(0, 0, 0))

		local sequence = self.Job.sequence or F4Menu.Config.DefaultJobSequence
		local holdingWep = self.Job.weaponCarry
		if (holdingWep) then
			local seq = self.Model.Entity:LookupSequence("idle_passive")
			if (seq) then
				self.Model.Entity:SetSequence(seq)

				local attachment = "anim_attachment_RH"
				local attachmentPos = self.Model.Entity:GetAttachment(self.Model.Entity:LookupAttachment(attachment)).Pos
				
				local wepMdl = weapons.Get(holdingWep).WorldModel
				self.Model.Entity.Wep = ClientsideModel(wepMdl)
				self.Model.Entity.Wep:SetOwner(self.Model.Entity)
				self.Model.Entity.Wep:SetPos(attachmentPos)
				self.Model.Entity.Wep:SetSolid(SOLID_NONE)
				self.Model.Entity.Wep:SetParent(self.Model.Entity)
				self.Model.Entity.Wep:SetNoDraw(true)
				self.Model.Entity.Wep:SetIK(false)
				self.Model.Entity.Wep:AddEffects(EF_BONEMERGE)
				self.Model.Entity.Wep:SetAngles(self.Model.Entity:GetForward():Angle())
				local matrix = Matrix()
				matrix:Scale(Vector(0.5, 0.5, 0.5))
				self.Model.Entity.Wep:EnableMatrix("RenderMultiply", matrix)
								self.Model.Entity.Wep:Spawn()
			end
		elseif (sequence) then
			self.Model.Entity:SetSequence(self.Model.Entity:LookupSequence(sequence))
		end
	end
	
end

function PANEL:SetActionButton(reason, color, canChange)
	self.Bottom.Action.Color = color
	self.Bottom.Action:SetText(reason:upper())
	self.Bottom.Action.CanChange = canChange
end

function PANEL:SetJob(job)
	self.JobID = job
	self.Job = RPExtraTeams[job]

	local ply = LocalPlayer()
	local amountInTeam = #team.GetPlayers(job)
	local teamLimit = self.Job.max
	local customCheck = true
	if (self.Job.customCheck) then
		customCheck = self.Job.customCheck(ply)
	end

	if (ply:Team() == job) then
		self:SetActionButton(F4Menu:GetPhrase("jobs.slideout.button.areThisJob"), XeninUI.Theme.Red)
	elseif (teamLimit > 0 and amountInTeam >= teamLimit) then
		self:SetActionButton(F4Menu:GetPhrase("jobs.slideout.button.jobIsFull"), XeninUI.Theme.Red)
	elseif (!customCheck) then
		self:SetActionButton(F4Menu:GetPhrase("jobs.slideout.button.customCheckFailed"), XeninUI.Theme.Red)
	elseif (self.Job.level and LevelSystemConfiguration and ply:getDarkRPVar("level") < self.Job.level) then
		self:SetActionButton(F4Menu:GetPhrase("jobs.slideout.button.tooLowLevel"), XeninUI.Theme.Red)
	end

	local mdl = istable(self.Job.model) and self.Job.model[1] or self.Job.model
	self:SetModel(mdl)
	self.Model:ClearModels()
	self.Model:SetModels(self.Job.model)

	local descTabStr = F4Menu:GetPhrase("jobs.slideout.tabs.description")
	local descTab = self.Tabs.panels[descTabStr]
	local isHtml = self.Job.isHTML
	descTab:SetContent(self.Job.description, isHtml)

	self.Info.Name = self.Info:Add("DLabel")
	self.Info.Name:Dock(TOP)
	self.Info.Name:DockMargin(8, 16, 8, 0)
	self.Info.Name:SetFont("F4Menu.Jobs.Slideout.Job")
	self.Info.Name:SetText(self.Job.name:upper())
	self.Info.Name:SetTextColor(color_white)
	self.Info.Name:SetWrap(true)
	self.Info.Name:SetAutoStretchVertical(true)

	if (self.Job.level) then
		self.Info.Level = self.Info:Add("DLabel")
		self.Info.Level:Dock(TOP)
		self.Info.Level:DockMargin(8, 0, 8, 0)
		self.Info.Level:SetFont("F4Menu.Jobs.Slideout.Level")
		self.Info.Level:SetWrap(true)
		self.Info.Level:SetAutoStretchVertical(true)
		self.Info.Level:SetText(F4Menu:GetPhrase("jobs.slideout.levelRequirement", { level = self.Job.level }))
		self.Info.Level:SetTextColor(Color(192, 192, 192))
	end

	if (!customCheck) then
		local err = isfunction(self.Job.CustomCheckFailMsg) and self.Job.CustomCheckFailMsg(LocalPlayer()) 
			or isstring(self.Job.CustomCheckFailMsg) and self.Job.CustomCheckFailMsg 
			or F4Menu:GetPhrase("jobs.slideout.button.customCheckFailed")

		self.Info.Error = self.Info:Add("DLabel")
		self.Info.Error:Dock(TOP)
		self.Info.Error:DockMargin(8, 0, 8, 0)
		self.Info.Error:SetText(err)
		self.Info.Error:SetTextColor(XeninUI.Theme.Red)
		self.Info.Error:SetFont("F4Menu.Jobs.Slideout.CustomCheck")
	end

	self.Donator = self.Job.ranks and !self.Job.ranks[ply:GetUserGroup()]
	if (self.Donator) then
		self.Info.Donator = self.Info:Add("DPanel")
		self.Info.Donator:Dock(TOP)
		self.Info.Donator:DockMargin(8, 16, 8, 16)
		self.Info.Donator.Shadow = 0
		self.Info.Donator:Lerp("Shadow", 1, 0.2)
		self.Info.Donator.Paint = function(pnl, w, h)
			if (!self.Donator) then return end

			local col = XeninUI.Theme.Primary
			local textCol = XeninUI.Theme.Yellow
			local aX, aY = pnl:LocalToScreen()
			local str = F4Menu:GetPhrase("jobs.slideout.donatorJob")
			surface.SetFont("F4Menu.Jobs.Slideout.Donator")
			local tw = surface.GetTextSize(str)
			local width = tw + 32
			if (pnl.Shadow >= 1) then
				BSHADOWS.BeginShadow()
					XeninUI:DrawRoundedBox(h / 2, aX, aY, width, h, col)
				BSHADOWS.EndShadow(1, 1, 1, 50)
			else
				XeninUI:DrawRoundedBox(h / 2, 0, 0, width, h, col)
			end

			XeninUI:DrawShadowText(str, "F4Menu.Jobs.Slideout.Donator", width / 2, h / 2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, 125)
		end
	end

	if (#self.Job.weapons > 0)then
		self.Tabs:AddTab(F4Menu:GetPhrase("jobs.slideout.tabs.weapons"), "F4Menu.Jobs.Slideout.Weapons")
		local tabStr = F4Menu:GetPhrase("jobs.slideout.tabs.weapons")
		local tab = self.Tabs.panels[tabStr]
		tab:SetWeapons(self.Job.weapons)
	end
	--self.Tabs:AddTab("RANKS")
end

function PANEL:Paint(w, h)
	XeninUI:DrawRoundedBoxEx(6, self.Info:GetWide(), 0, w - self.Info:GetWide(), h, XeninUI.Theme.Background, false, false, false, true)
end

function PANEL:PerformLayout(w, h)
	self.Info:SetWide(w * 0.5)
	if (IsValid(self.Info.Donator)) then
		self.Info.Donator:SetTall(36)
	end

	self.Tabs:SetPos(0, h * 0.3)
	self.Tabs:SetWide(self.Info:GetWide())
	self.Tabs:SetTall(36)

	self.Bottom:SetTall(64)
	if (self.Bottom.Action:IsVisible()) then
		self.Bottom.Action:AlignRight(24)
		self.Bottom.Action:SizeToContentsX(48)
		self.Bottom.Action:SizeToContentsY(16)
		self.Bottom.Action:CenterVertical()
	end

	local y = self.Tabs.y + self.Tabs:GetTall()
	self.Info.Content:SetPos(0, y)
	self.Info.Content:SetSize(self.Info:GetWide(), h - y - self.Bottom:GetTall())
end

vgui.Register("F4Menu.Jobs.Slideout", PANEL, "EditablePanel")