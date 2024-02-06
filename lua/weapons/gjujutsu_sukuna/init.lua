AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

-- Adding hooks

hook.Add("EntityTakeDamage", "gJujutsu_InfinityNoDamage", function(ply, dmg)
	if not ply:IsValid() then return end
	if not ply:IsPlayer() then return end
	if not ply:Alive() then return end
	local weapon = ply:GetActiveWeapon()

	local attacker = dmg:GetAttacker()
	local inflictor = dmg:GetInflictor()

	if weapon:Gjujutsu_IsGojo() and weapon:GetInfinity() then
		if attacker:IsValid() and weapon.DamageBypassEnts[attacker.Base] then return end
		if inflictor:IsValid() and weapon.DamageBypassEnts[inflictor.Base] then return end

		-- Need use this hack to remove knockback and screen punch
		timer.Simple(0, function()
			if not weapon:IsValid() then return end
			if not ply:IsValid() then return end
			local oldVelocity = ply.gJujutsu_OldVelocity
			local knockbackVelocity = oldVelocity - ply:GetVelocity()
			
			ply:SetVelocity(knockbackVelocity)
			ply:ViewPunchReset()
		end)

		return true
	end
end)
