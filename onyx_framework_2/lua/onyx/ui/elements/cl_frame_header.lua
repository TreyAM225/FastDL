-- by p1ng :D

PANEL = {}

local colorSecondary = onyx:Config('colors.secondary')

function PANEL:Init()
    self.lblText = self:Add('onyx.Label')
    self.lblText:CenterText()

    self.btnClose = self:Add('onyx.ImageButton')
    self.btnClose:SetWebImage('close', 'smooth mips')
    self.btnClose:InstallHoverAnim()
    self.btnClose:SetColorHover(Color(255, 87, 87))
    self.btnClose:SetColorPressed(Color(204, 38, 38))
    self.btnClose:SetImageScale(.6)
    self.btnClose.DoClick = function()
        self:GetParent():Close()
    end

    self:SetTitle('Title')
end

function PANEL:PerformLayout(w, h)
    -- self.lblText:Dock(FILL)
    self.lblText:SetSize(w, h)

    self.btnClose:Dock(RIGHT)
    self.btnClose:SetWide(h)
end

function PANEL:Paint(w, h)
    draw.RoundedBoxEx(8, 0, 0, w, h, colorSecondary, true, true)
end

function PANEL:SetTitle(text)
    self.lblText:SetText(onyx.utf8.upper(text))
end

onyx.gui.Register('onyx.Frame.Header', PANEL)