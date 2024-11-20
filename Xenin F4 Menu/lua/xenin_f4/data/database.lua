F4Menu.Database = {}
F4Menu.RichestPlayer = F4Menu.RichestPlayer or {}

function F4Menu.Database:GetConnection()
  return MySQLite
end

function F4Menu.Database:Tables()
  local conn = self:GetConnection()
  
  return XeninUI.Promises.all({
    XeninUI:InvokeSQL(conn, [[
      CREATE TABLE IF NOT EXISTS xenin_f4menu_activeplayers (
        sid BIGINT,
        lastLoggedIn BIGINT NOT NULL,
        PRIMARY KEY (sid)
      )
    ]], "F4Menu.ActivePlayers"),

    XeninUI:InvokeSQL(conn, [[
      CREATE TABLE IF NOT EXISTS xenin_f4menu_economysnapshots (
        time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
        money VARCHAR(35) NOT NULL,
        PRIMARY KEY (time)
      )
    ]], "F4Menu.EconomySnapshots")
  })
end

function F4Menu:SendEconomySnapshot(ply)
  local result = F4Menu.EconomySnapshot  or {}
  local entries = #result
  net.Start("F4Menu.EconomySnapshots")
    net.WriteUInt(entries, 9)
    for i = 1, entries do
      net.WriteFloat(result[i].money)
    end
  net.Send(ply)
end

function F4Menu.Database:SaveEconomySnapshot(money)
  local conn = self:GetConnection()
  local query = [[
    INSERT INTO xenin_f4menu_economysnapshots (money)
    VALUES (':money:')
  ]]
  query = query:Replace(":money:", money)

  return XeninUI:InvokeSQL(conn, query, "F4Menu.SaveEconomySnapshot." .. money)
end

function F4Menu.Database:GetEconomySnapshots(days)
  days = days or 7
  local conn = self:GetConnection()
  local isMySQL = conn.isMySQL()
  local offset = isMySQL and "INTERVAL " .. days .. " DAY" or (86400 * days)
  local time = isMySQL and "UNIX_TIMESTAMP(time)" or "strftime('%s', time)"
  local now = isMySQL and "now()" or "strftime('%s', 'now')"
  local query = [[
    SELECT money, :time: AS time FROM xenin_f4menu_economysnapshots
    WHERE time >= :now: - :offset:
    ORDER BY time DESC
    LIMIT ]] .. days * 24
  query = query:Replace(":offset:", offset)
  query = query:Replace(":time:", time)
  query = query:Replace(":now:",  now)

  local p = XeninUI:InvokeSQL(conn, query, "F4Menu.GetEconomySnapshots." .. days)
  p:next(function(result)
    F4Menu.EconomySnapshot = result
  end)
  p:next(function(result)
    F4Menu:SendEconomySnapshot(player.GetAll())
  end)

  return p
end

function F4Menu.Database:GetRichestPlayer()
  local conn = self:GetConnection()
  local cfg = F4Menu.Config.TotalMoney
  local days = cfg.DaysSinceLastLogin

  local power = conn.isMySQL() and "POWER(2, 32)" or "4294967296"
  local query = [[
    SELECT CAST(d.uid AS CHAR) AS uid, d.rpname, d.wallet 
    FROM darkrp_player AS d
    :join:
    WHERE d.uid >= :power:
      :and:
    ORDER BY d.wallet DESC
    LIMIT 1
  ]]
  query = query:Replace(":power:", power)
  
  if (days and days > 0) then
    local currentTime = os.time()
    local goBack = 60 * 60 * 24 * days
    local time = currentTime - goBack

    query = query:Replace(":and:", "AND a.lastLoggedIn >= " .. time)
    query = query:Replace(":join:", "INNER JOIN xenin_f4menu_activeplayers AS a ON d.uid = a.sid")
  else
    query = query:Replace(":join:", "")
    query = query:Replace(":and:", "")
  end

  return XeninUI:InvokeSQL(conn, query, "F4Menu.GetRichestPlayer"):next(function(result)
    result = result[1] or {}
    
    F4Menu.RichestPlayer = result
  end)
end

function F4Menu.Database:CacheOfflinePlayersMoney()
  local conn = self:GetConnection()
  local cfg = F4Menu.Config.TotalMoney
  local days = cfg.DaysSinceLastLogin

  local steamids = {}
  for i, v in ipairs(player.GetAll()) do
    table.insert(steamids, "'" .. v:SteamID64() .. "'")
  end
  
  local query = [[
    SELECT SUM(d.wallet) AS money
    FROM darkrp_player AS d
    :join:
    WHERE d.uid NOT IN (:steamids:) 
  ]]
  local str = table.concat(steamids, ",")
  if (str == "") then
    str = "''"
  end
  query = query:Replace(":steamids:", str)

  if (days and days > 0) then
    local currentTime = os.time()
    local goBack = 60 * 60 * 24 * days
    local time = currentTime - goBack

    query = query .. [[
      AND a.lastLoggedIn >= :time:
    ]]
    query = query:Replace(":join:", "INNER JOIN xenin_f4menu_activeplayers AS a ON d.uid = a.sid")
    query = query:Replace(":time:", time)
  else
    query = query:Replace(":join:", "")
  end

  return XeninUI:InvokeSQL(conn, query, "F4Menu.CacheOfflinePlayersMoney"):next(function(result)
    F4Menu.OfflinePlayersMoney = result[1] and result[1].money or 0

    net.Start("F4Menu.OfflinePlayersMoney")
      net.WriteString(F4Menu.OfflinePlayersMoney)
    net.Broadcast()
    
    XeninUI:Debounce("F4Menu.Cache", cfg.CacheInterval, function()
      self:CacheOfflinePlayersMoney(days)
    end)
  end)
end

function F4Menu.Database:UpdateActivePlayer(ply)
  local conn = self:GetConnection()
  local sid64 = ply:SteamID64()
  local time = os.time()

  if (conn.isMySQL()) then
    local query = [[
      INSERT INTO xenin_f4menu_activeplayers (sid, lastLoggedIn)
      VALUES (':sid64:', :time:)
      ON DUPLICATE KEY
        UPDATE
          lastLoggedIn = :time:
    ]]
    query = query:Replace(":sid64:", sid64)
    query = query:Replace(":time:", time)

    return XeninUI:InvokeSQL(conn, query, "F4Menu.UpdateActivePlayer." .. sid64)
  else
    local query = [[
      SELECT * FROM xenin_f4menu_activeplayers
      WHERE sid = ':sid64:'
    ]]
    query = query:Replace(":sid64:", sid64)
    
    local p = XeninUI:InvokeSQL(conn, query, "F4Menu.UpdateActivePlayer.Select." .. sid64)
    p:next(function(result)
      if (istable(result) and #result > 0) then
        local query = [[
          UPDATE xenin_f4menu_activeplayers
          SET lastLoggedIn = :time:
          WHERE sid = ':sid64:'
        ]]
        query = query:Replace(":sid64:", sid64)
        query = query:Replace(":time:", time)

        return XeninUI:InvokeSQL(conn, query, "F4Menu.UpdateActivePlayer." .. sid64)
      else
        local query = [[
          INSERT INTO xenin_f4menu_activeplayers (sid, lastLoggedIn)
          VALUES (':sid64:', :time:)
        ]]
        query = query:Replace(":sid64:", sid64)
        query = query:Replace(":time:", time)

        return XeninUI:InvokeSQL(conn, query, "F4Menu.UpdateActivePlayer." .. sid64)
      end
    end)

    return p
  end
end

hook.Add("DarkRPDBInitialized", "F4Menu.Caching", function()
  F4Menu.Database:Tables():next(function()
    F4Menu.Database:CacheOfflinePlayersMoney()
    F4Menu.Database:GetEconomySnapshots()
    F4Menu.Database:GetRichestPlayer()
  end):next(function()
    timer.Create("F4Menu.MoneyGraphData", 3600, 0, function()
      F4Menu.Database:CacheOfflinePlayersMoney():next(function()
        local money = tonumber(F4Menu.OfflinePlayersMoney)
        for i, v in ipairs(player.GetAll()) do
          money = money + (v:getDarkRPVar("money") or 0)
        end

        F4Menu.Database:SaveEconomySnapshot(money)
      end)
    end)
    timer.Create("F4Menu.RichestPlayerCache", 1800, 0, function()
      F4Menu.Database:GetRichestPlayer():next(function()
        local result = F4Menu.RichestPlayer

        net.Start("F4Menu.RichestPlayer")
          net.WriteString(result.rpname or "Unknown name")
          net.WriteString(tostring(result.uid) or "")
          net.WriteString(tostring(result.wallet) or "0")
        net.Broadcast()
      end)
    end)
  end)
end)

hook.Add("PlayerInitialSpawn", "F4Menu.Caching", function(ply)
  if (IsValid(ply)) then
    F4Menu.Database:UpdateActivePlayer(ply):next(function()
      F4Menu.Database:CacheOfflinePlayersMoney()
    end)
  end
end)
