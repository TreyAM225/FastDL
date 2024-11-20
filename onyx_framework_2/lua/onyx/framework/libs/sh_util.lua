--[[

Author: tochnonement
Email: tochnonement@gmail.com

01/05/2023

--]]

function onyx.WaitForGamemode(id, fn)
    if (GM or GAMEMODE) then
        fn()
    else
        if (SERVER) then
            hook.Add('PostGamemodeLoaded', id, fn) -- I hate ULX lol (`InitPostEntity` doesn't get called on serverside :\\\\)
        else
            hook.Add('InitPostEntity', id, fn) -- 'PostGamemodeLoaded' ain't called on CLIENT with uLib
        end
    end
end

function onyx.AssertType(variable, expected, funcname, pos)
    local given = type(variable)
    assert(given == expected, string.format('bad argument #%i to \'%s\' (expected %s, got %s)', pos, funcname, expected, given))
end

function onyx.ColorToHex(color)
    local r = bit.tohex(color.r, 2)
    local g = bit.tohex(color.g, 2)
    local b = bit.tohex(color.b, 2)

    return ('#' .. r .. g .. b)
end

function onyx.HexToColor(color)
    color = color:gsub('#', '')

    local r = tonumber('0x' .. color:sub(1, 2))
    local g = tonumber('0x' .. color:sub(3, 4))
    local b = tonumber('0x' .. color:sub(5, 6))

    return Color(r, g, b)
end

function onyx.MultiArg(arg, amount)
    local tbl = {}
    for i = 1, amount do
        tbl[i] = arg
    end
    return unpack(tbl)
end

do
    local replacements = {
        TypeToString = {
            ['boolean'] = 'b',
            ['number'] = 'n',
            ['string'] = 's',
            ['Vector'] = 'v',
            ['Angle'] = 'a',
        },
        StringToType = {
            ['b'] = 'bool',
            ['n'] = 'int',
            ['s'] = 'string',
            ['v'] = 'vector',
            ['a'] = 'angle',
            ['f'] = 'float'
        },
    }

    function onyx.TypeToString(any)
        local name = replacements.TypeToString[type(any)]
        assert(name, 'wrong type (' .. type(any) .. ')')
        local str = util.TypeToString(any)
        if (name == 'n' and (any % 1) ~= 0) then
            name = 'f'
        end
        local full = name .. '!' .. str
        return full
    end

    function onyx.StringToType(str)
        local typeShort = str:match('%w!-')
        local value = str:gsub(typeShort .. '!', '', 1)
        local typeFull = replacements.StringToType[typeShort]
        return util.StringToType(value, typeFull)
    end
end

if (SERVER) then
    util.AddNetworkString('onyx:Notify')

    function onyx.Notify(ply, text, notificationType, length)
        assert(IsEntity(ply), Format('bad argument #1 to `onyx.Notify` (expected player, got %s)', type(ply)))
        assert(isstring(text), Format('bad argument #2 to `onyx.Notify` (expected string, got %s)', type(text)))

        net.Start('onyx:Notify')
            net.WriteString(text)
            net.WriteUInt(notificationType or 0, 3)
            net.WriteUInt(length or 3, 4)
            net.WriteBool(false)
        net.Send(ply)
    end

    function onyx.NotifyLocalized(ply, text, args, notificationType, length)
        assert(IsEntity(ply), Format('bad argument #1 to `onyx.NotifyLocalized` (expected player, got %s)', type(ply)))
        assert(isstring(text), Format('bad argument #2 to `onyx.NotifyLocalized` (expected string, got %s)', type(text)))
        assert(istable(args), Format('bad argument #3 to `onyx.NotifyLocalized` (expected table, got %s)', type(args)))

        net.Start('onyx:Notify')
            net.WriteString(text)
            net.WriteUInt(notificationType or 0, 3)
            net.WriteUInt(length or 3, 4)
            net.WriteBool(true)
            onyx.net.WriteTable(args)
        net.Send(ply)
    end
else
    net.Receive('onyx:Notify', function(len)
        local text = net.ReadString()
        local notificationType = net.ReadUInt(3)
        local length = net.ReadUInt(4)
        local bLocalized = net.ReadBool()
        local arguments = bLocalized and onyx.net.ReadTable()

        if (bLocalized) then
            text = onyx.lang:Get(text, arguments)
        end

        notification.AddLegacy(text, notificationType, length)
    end)
end