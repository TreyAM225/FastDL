util.AddNetworkString("F4Menu.OfflinePlayersMoney")
util.AddNetworkString("F4Menu.EconomySnapshots")
util.AddNetworkString("F4Menu.RichestPlayer")
util.AddNetworkString("F4Menu.Open")

net.Receive("F4Menu.EconomySnapshots", function(len, ply)
  local requested = ply.__economySnapshotRequested
  if ((requested or 0) > CurTime()) then return end
  ply.__economySnapshotRequested = CurTime() + 30

  F4Menu:SendEconomySnapshot(ply)
end)

net.Receive("F4Menu.RichestPlayer", function(len, ply)
  local requested = ply.__hasRequestedRichestPlayer
  if (requested) then return end
  ply.__hasRequestedRichestPlayer = true
  
  local result = F4Menu.RichestPlayer
  net.Start("F4Menu.RichestPlayer")
    net.WriteString(result.rpname or "Unknown name")
    net.WriteString(tostring(result.uid) or ply:SteamID64())
    net.WriteString(tostring(result.wallet) or "0")
  net.Send(ply)
end)

net.Receive("F4Menu.OfflinePlayersMoney", function(len, ply)
  local requested = ply.__hasRequestedOfflineMoney
  if (requested) then return end
  ply.__hasRequestedOfflineMoney = true

  net.Start("F4Menu.OfflinePlayersMoney")
    net.WriteString(tostring(F4Menu.OfflinePlayersMoney))
  net.Send(ply)
end)

hook.Add("ShowSpare2", "F4Menu.OpenMenu", function(ply)
  net.Start("F4Menu.Open")
  net.Send(ply)
end)