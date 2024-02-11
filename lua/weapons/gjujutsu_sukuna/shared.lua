SWEP.PrintName = "Sukuna"
SWEP.Author = "Tom"
SWEP.Instructions = "Limitless Techniques"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Category = "gJujutsu"
SWEP.Base = "gjujutsu_base"  

SWEP.ViewModel = ''
SWEP.WorldModel = ''

SWEP.ViewModelFOV = 54
SWEP.UseHands = true
SWEP.HoldType = "sukuna"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Model = Model("models/gjujutsu/sukuna/sukuna.mdl")

SWEP.Abilities = {
	[AbilityKey.Ability3] = "Dismantle",
	[AbilityKey.Ability4] = "Cleave",
	[AbilityKey.Ability5] = "Fuga",
	[AbilityKey.Ability6] = "InfinityActivate",
	[AbilityKey.Ability7] = "SixEyesActivate",
	[AbilityKey.Ability8] = "ReverseTechnique",
	[AbilityKey.Ultimate] = "StartDomain",
	[AbilityKey.Taunt] = nil,
	[AbilityKey.Primary] = nil,
	[AbilityKey.Secondary] = "TeleportHold",
}

SWEP.AbilitiesUp = {
	[AbilityKey.Ability3] = "BlueRemove",
	[AbilityKey.Ability4] = "RedFire",
	[AbilityKey.Ability5] = "HollowPurpleFire",
	[AbilityKey.Ability6] = nil,
	[AbilityKey.Ability7] = nil,
	[AbilityKey.Ability8] = nil,
	[AbilityKey.Ultimate] = nil,
	[AbilityKey.Taunt] = nil,
	[AbilityKey.Primary] = nil,
	[AbilityKey.Secondary] = "Teleport",
}

SWEP.DefaultHealth = 3000
SWEP.DefaultMaxHealth = 3000

SWEP.PrimaryCD = 0
SWEP.SecondaryCD = 3
SWEP.Ability3CD = 2
SWEP.Ability4CD = 10
SWEP.Ability5CD = 25
SWEP.Ability6CD = 0.5
SWEP.Ability7CD = 0.5
SWEP.Ability8CD = 0.5
SWEP.UltimateCD = 50
SWEP.TauntCD = 0

SWEP.PrimaryCost = 0
SWEP.SecondaryCost = {Min = 25, Max = 250}
SWEP.Ability3Cost = 100
SWEP.Ability4Cost = 500
SWEP.Ability5Cost = {Min = 1000, Max = 3000}
SWEP.Ability6Cost = 25
SWEP.Ability7Cost = 0
SWEP.Ability8Cost = 0
SWEP.UltimateCost = 1500
SWEP.TauntCost = 0

SWEP.DefaultCursedEnergy = 3500
SWEP.DefaultMaxCursedEnergy = 3500
SWEP.DefaultCursedEnergyRegen = 0.15
SWEP.DefaultHealthGain = 3

SWEP.HealthGain = 3
SWEP.CursedEnergyDrain = 1.5 -- Per tick

SWEP.DomainRange = 7000

SWEP.HealthPerFinger = 1150
SWEP.EnergyPerFinger = 1500
SWEP.HealthGainPerFinger = 0.45 -- For reverse curse technique
SWEP.EnergyGainPerFinger = 0.01

SWEP.ClashPressScore = 2

gebLib.ImportFile("includes/thinks.lua")
gebLib.ImportFile("includes/cinematics.lua")

function SWEP:SetupDataTables()
	self:DefaultDataTables()

	self:NetworkVar("Int", 0, "Fingers")
end

function SWEP:Initialize()
	self:DefaultInitialize()

	self:SetFingers(1)

	self:SetCursedEnergy(self.DefaultCursedEnergy)
	self:SetMaxCursedEnergy(self.DefaultMaxCursedEnergy)
	self:SetCursedEnergyRegen(self.DefaultCursedEnergyRegen)
end

function SWEP:PostInitialize()
	self:DefaultPostInitialize()

	local owner = self:GetOwner()

	if owner:IsValid() then
		owner:SetBodygroup(1, 0)
	end
end

function SWEP:Deploy()
	self:DefaultDeploy()
end

function SWEP:Holster()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	if owner:IsFrozen() or not owner:Alive() then return end
	if self:GetBusy() then return end
	if self:GetDomainClash() then return end
	if self:GetInCinematic() then return end
	if self:GetDomain():IsValid() then return end

	self:DefaultHolster()
	return true
end

local actIndex = {
	["sukuna"] = ACT_HL2MP_IDLE
}

function SWEP:SetWeaponHoldType(holdType)
	holdType = string.lower(holdType)
	local index = actIndex[holdType]
    local owner = self:GetOwner()

	if not owner:IsValid() then return end
    if holdType == "sukuna" then
        self.ActivityTranslate = {}
        self.ActivityTranslate[ACT_MP_STAND_IDLE] = owner:GetSequenceActivity(owner:LookupSequence("Idle"))
        self.ActivityTranslate[ACT_MP_WALK] = ACT_HL2MP_IDLE + 1
        self.ActivityTranslate[ACT_MP_RUN] = ACT_HL2MP_RUN_FAST
        self.ActivityTranslate[ACT_MP_CROUCH_IDLE] = owner:GetSequenceActivity(owner:LookupSequence("pose_ducking_01"))
        self.ActivityTranslate[ACT_MP_CROUCHWALK] = index + 4
        self.ActivityTranslate[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = owner:GetSequenceActivity(owner:LookupSequence("range_fists_r"))
        self.ActivityTranslate[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = owner:GetSequenceActivity(owner:LookupSequence("range_fists_r"))
        self.ActivityTranslate[ACT_MP_RELOAD_STAND] = owner:GetSequenceActivity(owner:LookupSequence("gesture_item_place"))
        self.ActivityTranslate[ACT_MP_RELOAD_CROUCH] = owner:GetSequenceActivity(owner:LookupSequence("gesture_item_place"))
        self.ActivityTranslate[ACT_MP_JUMP] = owner:GetSequenceActivity(owner:LookupSequence("jump_knife"))
        self.ActivityTranslate[ACT_RANGE_ATTACK1] = index + 8
        self.ActivityTranslate[ACT_MP_SWIM] = index + 9
    end
end

function SWEP:Think()
	if not self.Initialized then
        self:Initialize()
        return
    end
	
    if self.Initialized and not self.PostInitialized then
        self:PostInitialize()
    end

	local owner = self:GetOwner()

	if owner:IsValid() then
		owner.gJujutsu_OldVelocity = owner:GetVelocity()
	end

	self:ReverseTechniqueThink()
	self:StatsRegenThink()
	self:ClampStatsThink()
	self:EventThink()
	self:ReversedActionClearThink()
	self:DomainClearThink()
	self:FingerStatsThink()

	if SERVER then
		self:NextThink(CurTime())
		return true
	end
end

function SWEP:PrimaryAttack()
	self:SetCursedEnergy(self:GetCursedEnergy() - 50)
	self:SetGlobalCD(2)
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:OnRemove()
end

-- Ability3
function SWEP:Dismantle()
	if CurTime() < self:GetNextAbility3() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability3Cost then return end

	local owner = self:GetOwner()

	local cd = self.Ability3CD
	
	if owner:KeyDown(IN_SPEED) then
		local nextSlash = 0

		for i = 1, 7 do
			timer.Simple(nextSlash, function()
				self:DismantleSlash(25 * self:GetFingers())
			end)
			nextSlash = nextSlash + 0.09
		end

		cd = cd * 3
	else 
		self:DismantleSlash(75 * self:GetFingers())
	end


	self:SetNextAbility3(CurTime() + cd)
end

function SWEP:DismantleSlash(damage)
	local owner = self:GetOwner()
	local ownerPos = owner:GetPos()
	local aimVector = owner:GetAimVector()
	
	if SERVER then
		owner:EmitSound(Sound("misc/cloth_whoosh_1.wav"))
		owner:EmitSound(Sound("sukuna/sfx/dismantle_slash.wav"))
	end
	owner:ViewPunch( Angle( -10, 0, 0 ) )

	local force = aimVector * 50000

	local damageInfo = DamageInfo()
	damageInfo:SetDamageType(5)
	if owner:IsValid() then damageInfo:SetAttacker(owner) end
	if self:IsValid() then damageInfo:SetInflictor(self) end
	damageInfo:SetDamage(damage)
	damageInfo:SetDamageForce(force)

	owner:LagCompensation(true)
	for _, ent in ipairs(ents.FindInCone(ownerPos, aimVector, 1500, 0.8)) do

		if SERVER then
			SuppressHostEvents(nil)
			ent:TakeDamageInfo(damageInfo)
			SuppressHostEvents(owner)
		end

		if CLIENT and ent:IsSolid() then
			CreateParticleSystemNoEntity("dismantle_slash", ent:GetPos())

			if ent:gebLib_IsPerson() then
				CreateParticleSystemNoEntity("blood_impact_red_01", ent:GetPos())
			end
		end

		if SERVER then
			ent:EmitSound(Sound("sukuna/sfx/slash_prop_hit1.wav"))
		end

		if ent:gebLib_IsPerson() then
			if SERVER then
				ent:EmitSound(Sound("sukuna/sfx/slash_body_hit" .. math.random(1, 2) .. ".wav"))	
			end
		end

		if ent:gebLib_IsProp() then
			ent:SetVelocity(force)
			
			local phys = ent:GetPhysicsObject()
			
			if phys:IsValid() then
				phys:SetVelocity(force)
			end

			if SERVER then
				SukunaPropCut(owner, ent, -45)
			end
		end
	end
	owner:LagCompensation(false)
end

-- Ability4
function SWEP:Cleave()
	if CurTime() < self:GetNextAbility4() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability4Cost then return end

end

-- Ability5
function SWEP:Fuga()
	if CurTime() < self:GetNextAbility5() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability5Cost.Min then return end

	return true
end

-- Ability6
function SWEP:InfinityActivate()
	if CurTime() < self:GetNextAbility6() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability6Cost then return end
	self:SetNextAbility6(CurTime() + self.Ability6CD)


	return true
end

-- Ability7
function SWEP:SixEyesActivate() 
	if CurTime() < self:GetNextAbility7() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability7Cost then return end
	self:SetNextAbility7(CurTime() + self.Ability7CD)
end

-- Ability8
function SWEP:ReverseTechnique() 
	if CurTime() < self:GetNextAbility8() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability8Cost then return end
	self:SetNextAbility8(CurTime() + self.Ability8CD)

	self:SetReverseTechniqueEnabled(not self:GetReverseTechniqueEnabled())
	self:ReverseCursedEffect()
	
	return true
end

-- Ultimate
function SWEP:StartDomain()
	if self:GetClashStart() then return end
	if self:GetDomainClash() then return end

	local domain = self:GetDomain()

	if domain:IsValid() then
		if SERVER and self:GetInCinematic() then
			net.Start("gJujutsu_cl_clearCamera")
			net.WriteEntity(owner)
			net.Broadcast()
		end

		if SERVER then
			domain:Remove()
		end

		return
	end

	if CurTime() < self:GetNextUltimate() and not domain:IsValid() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.UltimateCost and not domain:IsValid() then return end

	local owner = self:GetOwner()

	self:WindEffect(200, 0.55)

	if SERVER then
		owner:Freeze(true)
	end

	if SERVER then
		util.ScreenShake(owner:GetPos(), 10, 10, 1, 500, true)
		owner:EmitSound(Sound("sukuna/voice/domain_start.wav"))
	end

	if CLIENT then return end

	local clashData = owner:Gjujutsu_GetDomainClashData()

	if clashData then
		table.insert(clashData.Players, owner)
	else
		for _, ply in player.Pairs() do
			local weapon = ply:GetActiveWeapon()

			if not weapon:IsValid() then continue end
			if not weapon:IsGjujutsuSwep() then continue end
			if not weapon:GetDomainClash() then continue end

			local distance = owner:GetPos():Distance(ply:GetPos())

			if distance <= weapon.DomainRange + self.DomainRange then
				print("Close in to clash")

				local nearClashData = ply:Gjujutsu_GetDomainClashData()

				print(tostring(owner) .. " joined the clash of " .. tostring(nearClashData.Players[1]))

				table.insert(nearClashData.Players, owner)
				return
			end
		end

		print("Creating own clash")
		owner:CreateDomainClashTable()
	end

	self:SetDomainClash(true)
	self:SetClashStart(true)
end

function SWEP:DomainExpansion()
	local domain = self:GetDomain()

	local owner = self:GetOwner()
	local aimAngles = owner:GetAimVector():Angle()
	aimAngles.x = 0

	if SERVER then
		owner:Freeze(true)
	end

	self:SetBusy(true)
	self:SetDomainClash(false)
	self:SetClashStart(false)
	
	if SERVER then
		local domain = ents.Create("sukuna_domain")
		self:SetDomain(domain)
		domain:SetDomainOwner(owner)
		domain:SetPos(owner:GetPos() + aimAngles:Forward() * -265)
		domain:SetAngles(aimAngles)
		domain:Spawn()
		domain:Activate()
	end

	self:DomainExpansionCinematic()

	self:RemoveCursedEnergy(self.UltimateCost)
end

-- Secondary ability
function SWEP:TeleportHold()
end

function SWEP:Teleport()
	if CurTime() < self:GetSecondary() then return end

	self:SetSecondary(CurTime() + self.SecondaryCD)
end

-- Adding hooks
