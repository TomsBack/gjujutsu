gJujutsu_Debris = {
	Model("models/props_debris/concrete_chunk05g.mdl"),
	Model("models/props_debris/concrete_chunk04a.mdl"),
	Model("models/props_debris/concrete_chunk03a.mdl"),
	Model("models/props_debris/concrete_chunk02a.mdl"),
	Model("models/props_debris/concrete_spawnchunk001d.mdl"),
	Model("models/props_debris/concrete_spawnchunk001c.mdl")
}

if SERVER then
	resource.AddWorkshop( "3056680936" )
	resource.AddFile( "resource/fonts/20686.ttf" )
end

local PLAYER_META = FindMetaTable("Player")

if CLIENT then
	net.Receive("jjk.LoadNombat", function()
		hook.Add("PlayerSwitchWeapon", "gjujutsuNombatCompatibility", function(ply, owep, wep)
			if NOMBAT and wep:IsValid() and string.StartWith(wep:GetClass(), "gjujutsu_") then
				NOMBAT:SetCombatSong( "nombat/gjujutsu/"..wep:GetClass()..".wav", NiceDuration(SoundDuration("nombat/gjujutsu/"..wep:GetClass()..".mp3")) )
				NOMBAT.GetCombatTimeout = CurTime() + NiceDuration(SoundDuration("nombat/gjujutsu/"..wep:GetClass()..".mp3"))
			end
		end)
		hook.Add("HUDWeaponPickedUp", "gjujutsuNombatCompatibility", function(wep)
			if NOMBAT and wep:IsValid() and string.StartWith(wep:GetClass(), "gjujutsu_") then
				NOMBAT:SetCombatSong( "nombat/gjujutsu/"..wep:GetClass()..".mp3", NiceDuration(SoundDuration("nombat/gjujutsu/"..wep:GetClass()..".mp3")) )
				NOMBAT.GetCombatTimeout = CurTime() + NiceDuration(SoundDuration("nombat/gjujutsu/"..wep:GetClass()..".mp3"))
			end
		end)
		hook.Add("Think", "gjujutsuNombatCompatibility", function(ply, wep)
			local wep = LocalPlayer():GetActiveWeapon()
			if NOMBAT and wep:IsValid() and string.StartWith(wep:GetClass(), "gjujutsu_") and CurTime() >= NOMBAT.GetCombatTimeout then
				NOMBAT:SetCombatSong( "nombat/gjujutsu/"..wep:GetClass()..".mp3", NiceDuration(SoundDuration("nombat/gjujutsu/"..wep:GetClass()..".mp3")) )
				NOMBAT.GetCombatTimeout = CurTime() + NiceDuration(SoundDuration("nombat/gjujutsu/"..wep:GetClass()..".mp3"))
			end
		end)
	end)

	function Nombat_Cl_Init(  )
		local pl = LocalPlayer() -- (DONT EDIT)
		if IsValid(pl) then
			if pl then
				pl.NOMBAT_Level = 1 -- (DONT EDIT)
				pl.NOMBAT_PostLevel = 1 -- (DONT EDIT)
				local Ambient_Time = {36,40,30,61} --$ song time (in seconds)
				pl.NOMBAT_Amb_Delay = CurTime() -- (DONT EDIT)
				local Combat_Time = {148} --$ song time (in seconds)
				pl.NOMBAT_Com_Delay = CurTime() -- (DONT EDIT)
				pl.NOMBAT_Com_Cool = CurTime() -- (DONT EDIT)
				local packName = "gjujutsu" --$ MAKE SURE THIS IS THE SAME AS THE FOLDER NAME HOLDING THE SOUNDS
				if !isstring(packName) then packName = tostring( packName )	end -- (DONT EDIT)
				packName = packName.."/" -- (DONT EDIT)
				local subTable = { packName, Ambient_Time, Combat_Time } -- (DONT EDIT)
				if !pl.NOMBAT_PackTable then -- (DONT EDIT)
					pl.NOMBAT_PackTable = {subTable} -- (DONT EDIT)
					else
					table.insert( pl.NOMBAT_PackTable, subTable ) -- (DONT EDIT)
				end
				pl.NOMBAT_SVol = 0 -- (DONT EDIT)
			end
		end
	end
	hook.Add( "InitPostEntity", "Nombat_Cl_Init_jjk", Nombat_Cl_Init ) --$ change the "Nombat_Cl_Init_GAMENAME" to "Nombat_Cl_Init_" and your game name.
end

if SERVER then
	util.AddNetworkString("jjk.LoadNombat")
	hook.Add("PlayerTick", "gjujutsuNombatCompatibility", function(ply)
		local wep = ply:GetActiveWeapon()
		if NOMBAT and wep:IsValid() and string.StartWith(wep:GetClass(), "gjujutsu_") then
			ply:ConCommand("nombat.client.has.hostiles")
		end
	end)
	local function RecursivePlayerCheck(ply)
		timer.Simple(5, function() 
			if ply:GetModel() != "player/default.mdl" then
				net.Start("jjk.LoadNombat")
				net.Send(ply)
				ply.NombatLoaded = true
			else 
				RecursivePlayerCheck(ply)
			end
		end)
	end
	hook.Add("PlayerSpawn", "LoadgJujutsuNombatCompat", function(ply, transition)
		if NOMBAT then
			if !ply.NombatLoaded and ply:GetModel() != "player/default.mdl" then
				net.Start("jjk.LoadNombat")
				net.Send(ply)
				ply.NombatLoaded = true
				elseif !ply.NombatLoaded then
				RecursivePlayerCheck(ply)
			end
		end
	end)
end
