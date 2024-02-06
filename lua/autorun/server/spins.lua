local TRIES = 5
local gJujutsu_defaultamount = 15
local defaultinnate = "Nothing"
util.AddNetworkString("gjujutsu_spins_control")
util.AddNetworkString("gjujutsu_innate_control")
local playersConnected = {}

gameevent.Listen( "OnRequestFullUpdate" )

hook.Add("OnRequestFullUpdate", "gJujutsu_InitialConnect", function(data)
    if not playersConnected[data.userid] then
        playersConnected[data.userid] = true
        --Needs to be run on the next tick, because this runs slighty before client stage, so we cannot send net messages to players
        timer.Simple(0, function()
            hook.Run("gJujutsu_PlayerFullyConnected", Player(data.userid))
        end)
    end
end)

function gJujutsu_CreateSQL_Spins_Table()
    sql.Query("CREATE TABLE IF NOT EXISTS gjujutsu_spins ( SteamID TEXT, spins_amount NUMBER )")
end

function gJujutsu_CreateSQL_Innate_Table()
    sql.Query("CREATE TABLE IF NOT EXISTS gjujutsu_innate ( SteamID TEXT, innate TEXT )")
end

function gJujutsu_SaveSpinsAmount(player, index)
    if not IsValid(player) then return end
    if not index then return end
    if not sql.TableExists("gjujutsu_spins") then gJujutsu_CreateSQL_Spins_Table() end
    local steamID = SQLStr(player:SteamID())
    local data = sql.Query("SELECT * From gjujutsu_spins WHERE SteamID = " .. steamID .. ";")

    if data then
        sql.Query("UPDATE gjujutsu_spins SET spins_amount = " .. SQLStr(index) .. " WHERE SteamID = " .. steamID  .. ";")
        else
        sql.Query("INSERT INTO gjujutsu_spins ( SteamID, spins_amount ) VALUES( " .. steamID .. ", " .. SQLStr(index) .. " );")
    end
end

function gJujutsu_SaveInnate(player, index)
    if not IsValid(player) then return end
    if not index then return end
    if not sql.TableExists("gjujutsu_innate") then gJujutsu_CreateSQL_Innate_Table() end
    local steamID = SQLStr(player:SteamID())
    local data = sql.Query("SELECT * From gjujutsu_innate WHERE SteamID = " .. steamID .. ";")

    if data then
        sql.Query("UPDATE gjujutsu_innate SET innate = " .. SQLStr(index) .. " WHERE SteamID = " .. steamID  .. ";")
        else
        sql.Query("INSERT INTO gjujutsu_innate ( SteamID, innate ) VALUES( " .. steamID .. ", " .. SQLStr(index) .. " );")
    end
end

function gJujutsu_JoinSetSpins(player)
    if not sql.TableExists("gjujutsu_spins") then gJujutsu_CreateSQL_Spins_Table() end
    local steamID = SQLStr(player:SteamID())

    local tries = 0
    local spins_amount = nil

    while tries <= TRIES do
        print("TRY: " .. tries)
        spins_amount = sql.QueryValue("SELECT spins_amount FROM gjujutsu_spins WHERE SteamID = " .. steamID .. ";")

        if spins_amount then
            break
        end

        tries = tries + 1
    end

    if not spins_amount then
        return "NO_STAND"
    end

    return spins_amount
end

hook.Add("gJujutsu_PlayerFullyConnected", "gJujutsu_InitialConnect2", function(ply)
    if not sql.TableExists("gjujutsu_innate") then gJujutsu_CreateSQL_Innate_Table() end
    local steamID = SQLStr(ply:SteamID())
    local checkply = sql.QueryValue("SELECT innate FROM gjujutsu_innate WHERE SteamID = " .. steamID .. ";")
    if checkply then
        ply.currentinnate = checkply
        else
        ply.currentinnate = defaultinnate
    end
    net.Start("gjujutsu_innate_control")
    net.WriteEntity(ply)
    net.WriteString(ply.currentinnate)
    net.Broadcast()
    if ply.currentinnate != defaultinnate then
        ply:Give(ply.currentinnate)
        print(ply:GetName().." have "..ply.currentinnate.." innate")
        else
        print(ply:GetName().." have't innate")
    end
end)

hook.Add("gJujutsu_PlayerFullyConnected", "gJujutsu_InitialConnect", function(ply)
    if not sql.TableExists("gjujutsu_spins") then gJujutsu_CreateSQL_Spins_Table() end
    local steamID = SQLStr(ply:SteamID())
    local checkply = sql.QueryValue("SELECT spins_amount FROM gjujutsu_spins WHERE SteamID = " .. steamID .. ";")
    if checkply then
        ply.spinsamount = tonumber(checkply)
        else
        ply.spinsamount = gJujutsu_defaultamount
    end
    net.Start("gjujutsu_spins_control")
    net.WriteEntity(ply)
    net.WriteInt(ply.spinsamount, 32)
    net.Broadcast()
    print(ply:GetName().." have "..ply.spinsamount.." spins")
end)

hook.Add("PlayerSpawn", "gJujutsu_Player_Spawn", function(ply)
    if ply.currentinnate != nil then
        ply:Give(ply.currentinnate)
    end
end)

hook.Add("PlayerDisconnected", "gJujutsu_PlayerDisconnected_Save_Amount", function(ply)
    gJujutsu_SaveSpinsAmount(ply, ply.spinsamount)
end)

function SpinInnate(ply)
    if ply.spinsamount >= 1 then
        print( "Rolled innate!" )
        ply.spinsamount = ply.spinsamount - 1
        if ply:HasWeapon("gjujutsu_gojo") and ply.currentinnate == "gjujutsu_gojo" then
            ply:StripWeapon("gjujutsu_gojo")
            elseif ply:HasWeapon("gjujutsu_sukuna") and ply.currentinnate == "gjujutsu_sukuna" then
            ply:StripWeapon("gjujutsu_sukuna")
        end
        if math.random(1,2) == 1 then
            ply:Give("gjujutsu_gojo")
            print(ply:GetName().." just got Limitless innate!")
            ply.currentinnate = "gjujutsu_gojo"
            else
            ply:Give("gjujutsu_sukuna")
            print(ply:GetName().." just got Sukuna's Vessel innate!")
            ply.currentinnate = "gjujutsu_sukuna"
        end
        net.Start("gjujutsu_spins_control")
        net.WriteEntity(ply)
        net.WriteInt(ply.spinsamount, 32)
        net.Broadcast()

        net.Start("gjujutsu_innate_control")
        net.WriteEntity(ply)
        net.WriteString(ply.currentinnate)
        net.Broadcast()
        ply:SelectWeapon(ply.currentinnate)
        gJujutsu_SaveSpinsAmount(ply, ply.spinsamount)
        gJujutsu_SaveInnate(ply, ply.currentinnate)
        else
        print( "Not enough spins to roll!" )
    end
end

concommand.Add( "gjujutsu_innate_roll", function( ply )
    SpinInnate(ply)
end )


concommand.Add( "gjujutsu_add_spins", function( ply, cmd, args )
    if ply:IsSuperAdmin() then
        local arg1 = string.lower( args[1] )
        local arg2 = tonumber(args[2])
        if ( arg1 and arg2 ) then
            if arg2 <= 0 then print( "argument #2 cannot be a zero or a negative number" ) return end 
            for k, player in ipairs( player.GetAll() ) do
                if !string.match( string.lower( player:GetName() ), arg1 ) then continue end
                local spinsAmount = player.spinsamount or 0
                player.spinsamount = spinsAmount + arg2
                net.Start("gjujutsu_spins_control")
                net.WriteEntity(player)
                net.WriteInt(player.spinsamount, 32)
                net.Broadcast()
                gJujutsu_SaveSpinsAmount(player, player.spinsamount)
                break
            end
        end
    end
end )

concommand.Add( "gjujutsu_reduce_spins", function( ply, cmd, args )
    if ply:IsSuperAdmin() then
        local arg1 = string.lower( args[1] )
        local arg2 = tonumber(args[2])
        if ( arg1 and arg2 ) then
            for k, player in ipairs( player.GetAll() ) do
                if arg2 > player.spinsamount then print( "argument #2 cannot be less than spins amount!" ) return end 
                if arg2 <= 0 then print( "argument #2 cannot be a zero or a negative number" ) return end 
                if !string.match( string.lower( player:GetName() ), arg1 ) then continue end
                local spinsAmount = player.spinsamount or 0
                player.spinsamount = spinsAmount - arg2
                net.Start("gjujutsu_spins_control")
                net.WriteEntity(player)
                net.WriteInt(player.spinsamount, 32)
                net.Broadcast()
                gJujutsu_SaveSpinsAmount(player, player.spinsamount)
                break
            end
        end
    end
end )
