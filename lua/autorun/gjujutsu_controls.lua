if SERVER then
	util.AddNetworkString("gJujutsu_cl_onButtonDown")
	util.AddNetworkString("gJujutsu_cl_onButtonUp")
end

local MPLY = FindMetaTable("Player")

local keysUpdateTime = 0.5
local nextKeysUpdate = 0

local allowedWeapons = { -- Table of weapons it should check for keys
	["gjujutsu_gojo"] = true,
	["gjujutsu_sukuna"] = true
}

function MPLY:gJujutsu_SetupKeys()
	local ability = AbilityKey
    local keys = {
		[self:GetInfoNum("gjujutsu_ability3_key", 0)] = ability.Ability3,
        [self:GetInfoNum("gjujutsu_ability4_key", 0)] = ability.Ability4,
		[self:GetInfoNum("gjujutsu_ability5_key", 0)] = ability.Ability5,
		[self:GetInfoNum("gjujutsu_ability6_key", 0)] = ability.Ability6,
		[self:GetInfoNum("gjujutsu_ability7_key", 0)] = ability.Ability7,
		[self:GetInfoNum("gjujutsu_ability8_key", 0)] = ability.Ability8,
        [self:GetInfoNum("gjujutsu_ultimate_key", 0)] = ability.Ultimate,
        [self:GetInfoNum("gjujutsu_taunt_key", 0)] = ability.Taunt,
        [self:GetInfoNum("gjujutsu_primary_key", 0)] = ability.Primary,
        [self:GetInfoNum("gjujutsu_secondary_key", 0)] = ability.Secondary,
    }

	self.gJujutsu_Keys = keys	

    return keys
end

local function onButtonDown(ply, btn)
	if not ply:IsValid() then return end
	if not ply:Alive() or ply:IsFrozen() then return end

	local weapon = ply:GetActiveWeapon()

	if not weapon:IsValid() then return end
	if not weapon:IsGjujutsuSwep() then return end
	
	-- Handle domain clashing
	if weapon:GetDomainClash() and ply.gJujutsu_ClashKey and btn == ply.gJujutsu_ClashKey then
		if CLIENT then
			ply:EmitSound("misc/key_press.wav")
			return
		end

		if ply.gJujutsu_ClashPresses == nil then
			ply.gJujutsu_ClashPresses = 0
		end

		ply.gJujutsu_ClashPresses = ply.gJujutsu_ClashPresses + weapon.ClashPressScore -- TODO: Make dynamic score point that depends on the swep you are using
		print(ply, "Presses", ply.gJujutsu_ClashPresses)
		return
	end

	if weapon:Gjujutsu_IsGojo() and not ply:OnGround() and weapon:GetInfinity() and btn == KEY_SPACE then
		if not weapon:GetFlying() then
			weapon:SetFlying(true)
			ply:SetMoveType(MOVETYPE_NOCLIP)
		else
			weapon:DisableFlight()
		end

		return
	end

	if not ply.gJujutsu_Keys then ply:gJujutsu_SetupKeys() end
	if not ply.gJujutsu_Keys[btn] then return end
	
	local abilityType = ply.gJujutsu_Keys[btn]
	local abilityFunction = weapon.Abilities[abilityType]

	if not weapon[abilityFunction] then
		print(tostring(weapon) .. " does not have assigned ability: " .. abilityType .. " please assign this ability a function, so it can do anything")
		return
	end

	if SERVER then
		-- Send to all players except the local one as he already ran the function
		net.Start("gJujutsu_cl_onButtonDown")
		net.WriteUInt(btn, 8)
		gebLib_net.WritePlayer(ply)
		gebLib_net.SendToAllExcept(ply)
	end

	weapon[abilityFunction](weapon)
end

local function onButtonUp(ply, btn)
	if not ply:IsValid() then return end
	if not ply:Alive() or ply:IsFrozen() then return end
	if not ply.gJujutsu_Keys then ply:gJujutsu_SetupKeys() end
	if not ply.gJujutsu_Keys[btn] then return end
	local weapon = ply:GetActiveWeapon()
	
	if not weapon:IsValid() then return end
	
	if weapon:IsGjujutsuSwep() then
		if weapon:GetDomainClash() then return end

		local abilities = weapon.AbilitiesUp
		
		if not abilities then return end
		
		local abilityType = ply.gJujutsu_Keys[btn]
		local abilityFunction = weapon.AbilitiesUp[abilityType]

		if not weapon[abilityFunction] then
			return
		end

		if SERVER then
			-- Send to all players except the local one as he already ran the function
			net.Start("gJujutsu_cl_onButtonUp")
			net.WriteUInt(btn, 8)
			gebLib_net.WritePlayer(ply)
			gebLib_net.SendToAllExcept(ply)
		end

		weapon[abilityFunction](weapon)
	end
end

hook.Add("PlayerButtonDown", "gJujutsu_ButtonDown", onButtonDown)
hook.Add("PlayerButtonUp", "gJujutsu_ButtonUp", onButtonUp)

hook.Add("Tick", "gJujutsu_UpdateKeys", function()
	if CurTime() < nextKeysUpdate then return end
	nextKeysUpdate = CurTime() + keysUpdateTime

	for _, ply in player.Pairs() do
		ply:gJujutsu_SetupKeys()
	end
end)

-- Receiving on the client
if CLIENT then
	net.Receive("gJujutsu_cl_onButtonDown", function()
		local btn = net.ReadUInt(8)
		local ply = gebLib_net.ReadPlayer()
		onButtonDown(ply, btn)
	end)

	net.Receive("gJujutsu_cl_onButtonUp", function()
		local btn = net.ReadUInt(8)
		local ply = gebLib_net.ReadPlayer()
		onButtonUp(ply, btn)
	end)
end
