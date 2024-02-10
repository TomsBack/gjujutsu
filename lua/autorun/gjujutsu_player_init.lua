
-- Set default values for the player
hook.Add("gebLib_PlayerFullyConnected", "gJujutsu_PlayerInit", function(ply)
	ply:gJujutsu_SetupKeys()

	ply.gJujutsu_ClashPresses = 0
	ply.gJujutsu_ClashKey = 0
	ply.gJujutsu_ClashKeyTime = 0

	print(tostring(ply) .. " Fully connected")
end)
