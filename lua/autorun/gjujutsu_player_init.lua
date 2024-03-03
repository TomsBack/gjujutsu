
-- Set default values for the player
hook.Add("gebLib_PlayerFullyConnected", "gJujutsu_PlayerInit", function(ply)
	ply:gJujutsu_SetupKeys()

	ply.gJujutsu_ClashPresses = 0
	ply.gJujutsu_ClashKey = 0
	ply.gJujutsu_ClashKeyTime = 0

	gebLib.PrintDebug(tostring(ply) .. " Fully connected")
end)

hook.Add("PostPlayerDeath", "gJujutsu_UnFreeze", function(ply)
	if ply:IsValid() then
		ply:Freeze(false)
	end
end)
