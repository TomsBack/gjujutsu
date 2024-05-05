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

		-- Clear camera of this entity for all clients
		net.Start("gJujutsu_cl_clearCamera")
		net.WriteEntity(ply)
		net.Broadcast()
	end
end)

local fireDamageMin = 20 -- You can't block continuous fire damage, so I'm naively looking for a small fire damage, so I know its the default one

hook.Add("EntityTakeDamage", "gJujutsu_BlockHandling", function(ent, dmg)
	if not ent:IsValid() then return end
	if not ent:IsPlayer() then return end
	if dmg:IsFallDamage() then return end
	if ent:IsOnFire() and dmg:GetDamageType() == DMG_BURN and dmg:GetDamage() <= fireDamageMin then return end
	if dmg:GetInflictor().Base == "domain_base" then return end
	local weapon = ent:GetActiveWeapon()

	if weapon:IsValid() and weapon:IsGjujutsuSwep() and weapon:GetBlock() then
		timer.Simple(0, function()
			if not ent:IsValid() then return end
			
			ent:Gjujutsu_ResetKnockback()
		end)

		if weapon:IsPerfectBlocking() then
			hook.Run("gJujutsu_OnPerfectBlock", weapon, dmg)

			net.Start("gJujutsu_cl_onPerfectBlock")
			net.WriteEntity(weapon)
			net.WriteInt(dmg:GetDamage(), 32)
			net.Broadcast()

			ent:EmitSound("misc/perfect_block.wav")

			dmg:ScaleDamage(weapon.PerfectBlockMult)
		else
			hook.Run("gJujutsu_OnBlock", weapon, dmg)

			net.Start("gJujutsu_cl_onBlock")
			net.WriteEntity(weapon)
			net.WriteInt(dmg:GetDamage(), 32)
			net.Broadcast()

			ent:EmitSound("misc/block.wav")

			dmg:ScaleDamage(weapon.BlockMult)
		end
	end
end)

hook.Add("EntityTakeDamage", "gJujutsu_DamageInsideDomain", function(ent, dmg)
	if not ent:IsPlayer() then return end
	if dmg:GetInflictor().Base ~= "domain_base" then return end
	local weapon = ent:GetActiveWeapon()

	if IsValid(weapon) and not weapon:IsGjujutsuSwep() then return end
	local domain = weapon:GetDomain()

	if domain:IsValid() and domain:IsInDomain(ent) then
		gebLib.PrintDebug("Player domain protecting from other player's domain damage")
		return true
	end
end)
