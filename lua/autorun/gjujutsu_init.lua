if SERVER then
	util.AddNetworkString("gJujutsu.LoadNombat")
end

if SERVER then
	resource.AddFile( "resource/fonts/20686.ttf" )
end

gJujutsu_Sweps = {
	["gjujutsu_gojo"] = true,
	["gjujutsu_sukuna"] = true
}

if CLIENT then
	local function SetNombatSong(weapon)
		if not weapon:IsValid() then return end

		local class = weapon:GetClass()
		local soundDuration = gebLib_SoundDuration("sound/nombat/gjujutsu/"..class..".mp3")

		NOMBAT:SetCombatSong("nombat/gjujutsu/"..class..".mp3", soundDuration)
		NOMBAT.GetCombatTimeout = CurTime() + soundDuration
	end

	net.Receive("gJujutsu.LoadNombat", function()
		if not NOMBAT then return end

		-- Precaching music durations for nombat
		print("Preacaching sounds for NOMBAT")
		for swepClass, _ in pairs(gJujutsu_Sweps) do
			gebLib_SoundDuration("sound/nombat/gjujutsu/" .. swepClass .. ".mp3")
		end

		hook.Add("PlayerSwitchWeapon", "gjujutsuNombatCompatibility", function(ply, oldWeapon, weapon)
			if weapon:IsValid() and weapon:IsGjujutsuSwep() then
				SetNombatSong(weapon)
			end
		end)
		hook.Add("HUDWeaponPickedUp", "gjujutsuNombatCompatibility", function(weapon)
			if weapon:IsValid() and weapon:IsGjujutsuSwep() then
				SetNombatSong(weapon)
			end
		end)
		hook.Add("Think", "gjujutsuNombatCompatibility", function()
			local ply = LocalPlayer()

			if not ply:IsValid() then return end
			local weapon = ply:GetActiveWeapon()
			
			if weapon:IsValid() and weapon:IsGjujutsuSwep() and CurTime() >= NOMBAT.GetCombatTimeout then
				SetNombatSong(weapon)
			end
		end)
	end)

	function Nombat_Cl_Init(  )
		local pl = LocalPlayer() -- (DONT EDIT)
		if pl:IsValid() then
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

	hook.Add( "InitPostEntity", "Nombat_Cl_Init_gJujutsu", Nombat_Cl_Init ) --$ change the "Nombat_Cl_Init_GAMENAME" to "Nombat_Cl_Init_" and your game name.
end

if SERVER then
	hook.Add("FinishMove", "gjujutsuNombatCompatibility", function(ply)
		if not NOMBAT then return end
		local weapon = ply:GetActiveWeapon()
		
		if weapon:IsValid() and weapon:IsGjujutsuSwep() then
			ply:ConCommand("nombat.client.has.hostiles")
		end
	end)

	hook.Add("gebLib_PlayerFullyConnected", "LoadgJujutsuNombatCompat", function(ply, transition)
		if not NOMBAT then return end

		net.Start("gJujutsu.LoadNombat")
		net.Send(ply)
		ply.NombatLoaded = true
	end)
end
