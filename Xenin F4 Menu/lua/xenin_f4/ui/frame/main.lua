local PANEL = {}
XeninUI:CreateFont("F4Menu.Category.Title", 24)

function PANEL:Init()
  F4Menu.Frame = self

  self.Active = 0

  self.Sidebar = self:Add("XeninUI.SidebarV2")
  self.Sidebar:Dock(LEFT)

  self.Player = self.Sidebar:Add("F4Menu.Player")
  self.Player:Dock(TOP)
  
  self.Background = self:Add("Panel")
  self.Background:Dock(FILL)
  self.Background.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBox(6, 0, 0, w, h, F4Menu.Config.Colors.Background, false, false, false, true)
  end
  
  self.Sidebar:SetBody(self.Background)
  
  for i, v in ipairs(F4Menu.Config.Tabs) do
    if (v.type == "divider") then
        self.Sidebar:CreateDivider(v.startColor, v.endColor)

      continue
    end

    if (v.type == "tab") then
      self.Sidebar:CreatePanel(v.name, v.desc, v.panel, v.icon, v)
    elseif (v.type == "url") then
      self.Sidebar:CreatePanel(v.name, v.desc, "F4Menu.URL", v.icon, v)
    elseif (v.type == "website") then
      self.Sidebar:CreatePanel(v.name, v.desc, "F4Menu.Website", v.icon, v)
    end
  end

  self.Sidebar:SetActiveByName(F4Menu.Config.DefaultTab)
  
  self.top.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, F4Menu.Config.Colors.Top, true, true, false, false)
  end
  self.Sidebar.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, F4Menu.Config.Colors.Sidebar, false, false, true, false)
  end
end

function PANEL:Think()
  local key = input.KeyNameToNumber(input.LookupBinding("gm_showspare2"))
  if (!key) then return end
  local keyDown = input.IsKeyDown(key)
  if (!self.OpenTime) then
    self.OpenTime = CurTime() + 0.75
  end

  if (keyDown and CurTime() >= self.OpenTime) then
    self:SetVisible(false)
  end
end

function PANEL:OnRemove()
  F4Menu.Frame = nil
end

function PANEL:PerformLayout(w, h)
  self.BaseClass.PerformLayout(self, w, h)

  local sw = 0
  for i, v in ipairs(self.Player.Text.Rows) do
    surface.SetFont(v.font)
    local tw = surface.GetTextSize(v.text)

    sw = math.max(sw, 68 + tw + 68 / 2 + 8)
  end
  for i, v in ipairs(self.Sidebar.Sidebar) do
    surface.SetFont("XeninUI.SidebarV2.Name")
    local nameTw = surface.GetTextSize(v.Name or "")
    surface.SetFont(v.DescFont)
    local descTw = surface.GetTextSize(v.Desc or "")

    local tw = math.max(nameTw, descTw) + 8
    if (v.Icon) then
      tw = tw + 68
    end

    sw = math.max(sw, tw)
  end

  self.Sidebar:SetWide(math.max(220, sw))
  self.Player:SetTall(68)
end
vgui.Register("F4Menu.Frame", PANEL, "XeninUI.Frame")

function F4Menu:OpenMenu()
  if (IsValid(F4Menu.Frame)) then 
    F4Menu.Frame.OpenTime = CurTime() + 0.75
    F4Menu.Frame:SetVisible(true)

    if (XeninUI.Debug) then
      F4Menu.Frame:Remove()
    else
      return 
    end
  end

  local frame = vgui.Create("F4Menu.Frame")
  local res = F4Menu.Config.Resolution
  local w, h
  if (isfunction(res)) then
    w, h = res()

    w = math.max(960, w * ScrW())
    h = math.max(600, h * ScrH())
  else
    w = res[1]
    h = res[2]
  end

  local width = math.min(ScrW(), w)
  local height = math.min(ScrH(), h)
  frame:SetSize(width, height)
  frame:Center()
  frame:MakePopup()
  if (!XeninUI.Debug) then
    frame.closeBtn.DoClick = function(pnl)
      frame:SetVisible(false)
    end
  end
  local title = F4Menu.Config.Title
  if (isfunction(title)) then
    frame:SetTitle(title())
    frame:AddTimer("F4Menu.Title", 10, 0, function()
      frame:SetTitle(title())
    end)
  else
    frame:SetTitle(title)
  end
end