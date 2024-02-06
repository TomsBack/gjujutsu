AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

-- Adding hooks

hook.Add("GetFallDamage", "gJujutsu_NoFallDamage", function(ply, speed)
	local weapon = ply:GetActiveWeapon()

	if weapon:IsGjujutsuSwep() then
		return 0
	end
end)

hook.Add("DoPlayerDeath", "gJujutsu_ClearCinematic", function(ply, attacker, dmg)
	local weapon = ply:GetActiveWeapon()

	if not weapon:IsGjujutsuSwep() then return end

	local domain = weapon:GetDomain()

	if domain:IsValid() then
		domain:Remove()
	end

	if weapon:GetInCinematic() then
		ply:Freeze(false)

		print("In cinematic. Clearing")

		-- Clear camera of this entity for all clients
		net.Start("gJujutsu_cl_clearCamera")
		net.WriteEntity(ply)
		net.Broadcast()
	end
end)
