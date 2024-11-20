net.Receive("F4Menu.OfflinePlayersMoney", function(len)
  local money = tonumber(net.ReadString())
  
  F4Menu.OfflinePlayersMoney = money
end)

net.Receive("F4Menu.RichestPlayer", function(len)
  local name = net.ReadString()
  local sid64 = net.ReadString()
  local money = tonumber(net.ReadString())

  F4Menu.RichestPlayer = {
    sid64 = sid64,
    money = money,
    name = name
  }

  hook.Run("F4Menu.RichestPlayer", F4Menu.RichestPlayer)
end)

net.Receive("F4Menu.EconomySnapshots", function(len)
  local entries = net.ReadUInt(9)
  local tbl = {}
  for i = 1, entries do
    tbl[#tbl + 1] = net.ReadFloat()
  end

  F4Menu.EconomySnapshots = tbl

  hook.Run("F4Menu.EconomySnapshots")
end)

net.Receive("F4Menu.Open", function(len)
  F4Menu:OpenMenu()
end)