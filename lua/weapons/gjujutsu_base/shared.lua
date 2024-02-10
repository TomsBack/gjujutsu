SWEP.PrintName = "gJujutsu Base"
SWEP.Author = "Tom"
SWEP.Instructions = ""
SWEP.Category = "gJujutsu" 

SWEP.Spawnable = false
SWEP.AdminOnly = true
SWEP.ViewModel = ''
SWEP.WorldModel = ''

SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Model = nil
SWEP.OldModel = nil

SWEP.Initialized = false
SWEP.PostInitialized = false

SWEP.DamageBypassEnts = {
	["hollow_purple"] = true,
}

SWEP.DamageBypassBase = {
	["domain_base"] = true,
}

SWEP.Abilities = {
	[AbilityKey.Ability3] = nil,
	[AbilityKey.Ability4] = nil,
	[AbilityKey.Ability5] = nil,
	[AbilityKey.Ability6] = nil,
	[AbilityKey.Ability7] = nil,
	[AbilityKey.Ability8] = nil,
	[AbilityKey.Ultimate] = nil,
	[AbilityKey.Taunt] = nil,
	[AbilityKey.Primary] = nil,
	[AbilityKey.Secondary] = nil,
}

SWEP.AbilitiesUp = {
	[AbilityKey.Ability3] = nil,
	[AbilityKey.Ability4] = nil,
	[AbilityKey.Ability5] = nil,
	[AbilityKey.Ability6] = nil,
	[AbilityKey.Ability7] = nil,
	[AbilityKey.Ability8] = nil,
	[AbilityKey.Ultimate] = nil,
	[AbilityKey.Taunt] = nil,
	[AbilityKey.Primary] = nil,
	[AbilityKey.Secondary] = nil,
}

SWEP.Ability3CD = 0
SWEP.Ability4CD = 0
SWEP.Ability5CD = 0
SWEP.Ability6CD = 0
SWEP.Ability7CD = 0
SWEP.Ability8CD = 0
SWEP.UltimateCD = 0
SWEP.TauntCD = 0

-- Cost is meant in cursed energy
SWEP.Ability3Cost = 0
SWEP.Ability4Cost = 0
SWEP.Ability5Cost = 0
SWEP.Ability6Cost = 0
SWEP.Ability7Cost = 0
SWEP.Ability8Cost = 0
SWEP.UltimateCost = 0
SWEP.TauntCost = 0

SWEP.DefaultDamageMultiplier = 1
SWEP.DamageMultiplier = 1

SWEP.DefaultHealth = 1000
SWEP.DefaultMaxHealth = 1000

SWEP.DefaultHealthGain = 2 -- Per tick
SWEP.HealthGain = 2 -- Per tick
SWEP.ExtinguishDrain = 25

SWEP.DefaultCursedEnergy = 1000
SWEP.DefaultMaxCursedEnergy = 1000
SWEP.DefaultCursedEnergyRegen = 0.15 -- Per tick
SWEP.CursedEnergyDrain = 1.75 -- Per tick

SWEP.RunSpeed = 800
SWEP.WalkSpeed = 350
SWEP.SlowWalkSpeed = 100
SWEP.JumpPower = 300

SWEP.OldWalk = -1
SWEP.OldSlowWalk = -1
SWEP.OldRun = -1
SWEP.OldJumpPower = -1

SWEP.DomainRange = 1500

SWEP.ClashPressScore = 1 -- Default score that is going to be added once the player presses the right key in domain clash
SWEP.DomainClearTreshold = 10 -- If the player has less than this in the domain. The domain will get cleared

SWEP.LastMoveType = MOVETYPE_WALK -- Is used to set the last moveable type before getting frozen

SWEP.ReverseCurseSound = Sound("misc/reverse_curse_activate.wav")

gebLib.ImportFile("includes/thinks.lua")

gJujutsu_EntsBlacklist = {
	["ba_stand_rewritten"] = true,
}

function SWEP:DefaultDataTables()
	self:NetworkVar("Entity", 31, "Domain")

	self:NetworkVar("Bool", 27, "ClashStart")
	self:NetworkVar("Bool", 27, "DomainClash")
	self:NetworkVar("Bool", 28, "InCinematic")
	self:NetworkVar("Bool", 29, "Busy")
	self:NetworkVar("Bool", 30, "ReverseTechniqueEnabled")
	self:NetworkVar("Bool", 31, "BlockCamera")

	self:NetworkVar("Float", 17, "Primary")
	self:NetworkVar("Float", 18, "Secondary")
	self:NetworkVar("Float", 19, "NextAbility3")
	self:NetworkVar("Float", 20, "NextAbility4")
	self:NetworkVar("Float", 21, "NextAbility5")
	self:NetworkVar("Float", 22, "NextAbility6")
	self:NetworkVar("Float", 23, "NextAbility7")
	self:NetworkVar("Float", 24, "NextAbility8")
	self:NetworkVar("Float", 25, "NextUltimate")
	self:NetworkVar("Float", 26, "NextTaunt")

	self:NetworkVar("Float", 27, "CursedEnergy")
    self:NetworkVar("Float", 28, "MaxCursedEnergy")
    self:NetworkVar("Float", 29, "CursedEnergyRegen")

	self:NetworkVar("Float", 31, "NextEvent")
	self:NetworkVar("String", 3, "Event")
end

function SWEP:DefaultInitialize()
	self.Initialized = true
	self:SetupDefaultValues()

	-- If its first time getting this weapon, then reset default values
	self.OldWalk = -1
	self.OldSlowWalk = -1
	self.OldRun = -1
	self.OldJumpPower = -1
	
	local owner = self:GetOwner()

	if owner:IsValid() then
		owner.gJujutsu_ClashPresses = 0
		owner.gJujutsu_ClashKey = 0
		owner.gJujutsu_ClashKeyTime = 0
	end

	self:SetHoldType(self.HoldType)
end

function SWEP:DefaultPostInitialize()
	self.PostInitialized = true
	self:SetupModel()
	self:SetupDefaultValues()

	self:SetHoldType(self.HoldType)

	self:EnableFlashlight(false)
end

function SWEP:DefaultDeploy()
	self:SetupModel()
	self:SetupDefaultValues()

	self:EnableFlashlight(false)
end

function SWEP:DefaultHolster()
	self:RestoreOldValues()

	self:EnableFlashlight(true)
end

function SWEP:SetupDefaultValues()
	self:SetBlockCamera(false)

	-- self:SetCursedEnergy(self.DefaultCursedEnergy)
	-- -- self:SetMaxCursedEnergy(self.DefaultMaxCursedEnergy)
	-- self:SetCursedEnergyRegen(self.DefaultCursedEnergyRegen)

	local owner = self:GetOwner()

	if not owner:IsValid() then return end

	if SERVER then
		owner:SetMaxHealth(self.DefaultMaxHealth)
	end
	owner:SetHealth(self.DefaultHealth)

	if self.OldWalk <= -1 then
		self.OldWalk = owner:GetWalkSpeed()
		self.OldSlowWalk = owner:GetSlowWalkSpeed()
		self.OldRun = owner:GetRunSpeed()
		self.OldJumpPower = owner:GetJumpPower()
	end

    owner:SetSlowWalkSpeed(self.SlowWalkSpeed)
    owner:SetWalkSpeed(self.WalkSpeed)
    owner:SetRunSpeed(self.RunSpeed)
	owner:SetJumpPower(self.JumpPower)
end

function SWEP:RestoreOldValues()
	local owner = self:GetOwner()

	if SERVER and owner:IsValid() then
		owner:SetModel(self.OldModel)
	end

	owner:SetSlowWalkSpeed(self.OldSlowWalk)
    owner:SetWalkSpeed(self.OldWalk)
    owner:SetRunSpeed(self.OldRun)
	owner:SetJumpPower(self.OldJumpPower)
end

function SWEP:SetupModel()
	local owner = self:GetOwner()

	if owner:IsValid() then

		self.OldModel = owner:GetModel()
		owner:SetModel(self.Model)
	end
end

function SWEP:EnableFlashlight(allow)
	local owner = self:GetOwner()

	if not owner:IsValid() then return end

	if SERVER and owner:FlashlightIsOn() then
		owner:Flashlight(false)
	end
	owner:AllowFlashlight(allow)
end

function SWEP:AddCursedEnergy(addAmount)
	self:SetCursedEnergy(math.Clamp(self:GetCursedEnergy() + addAmount, 0, self:GetMaxCursedEnergy()))
end

function SWEP:RemoveCursedEnergy(substractAmount)
	self:SetCursedEnergy(math.Clamp(self:GetCursedEnergy() - substractAmount, 0, self:GetMaxCursedEnergy()))
end

function SWEP:SetGlobalCD(cdAmount)
	local curTime = CurTime()

	self:SetPrimary(math.max(self:GetPrimary() + cdAmount, curTime + cdAmount))
	self:SetSecondary(math.max(self:GetSecondary() + cdAmount, curTime + cdAmount))
	self:SetNextAbility3(math.max(self:GetNextAbility3() + cdAmount, curTime + cdAmount))
	self:SetNextAbility4(math.max(self:GetNextAbility4() + cdAmount, curTime + cdAmount))
	self:SetNextAbility5(math.max(self:GetNextAbility5() + cdAmount, curTime + cdAmount))
	self:SetNextAbility6(math.max(self:GetNextAbility6() + cdAmount, curTime + cdAmount))
	self:SetNextAbility7(math.max(self:GetNextAbility7() + cdAmount, curTime + cdAmount))
	self:SetNextAbility8(math.max(self:GetNextAbility8() + cdAmount, curTime + cdAmount))
	self:SetNextUltimate(math.max(self:GetNextUltimate() + cdAmount, curTime + cdAmount))
	self:SetNextTaunt(math.max(self:GetNextTaunt() + cdAmount, curTime + cdAmount))
end

function SWEP:WindEffect(endSize, endTime)
	if SERVER then return end

	local owner = self:GetOwner()

	if not owner:IsValid() then return end

	local windWaveEnt = ents.CreateClientside("explosion_ent")
	windWaveEnt.SphereSize = endSize
	windWaveEnt.EffectTime = endTime
	windWaveEnt.StartAlpha = 100
	windWaveEnt:SetPos(owner:GetPos())
	windWaveEnt:Spawn()
end

function SWEP:ReverseCursedEffect()
	local owner = self:GetOwner()

	if not owner:IsValid() then return end
	
	if self:GetReverseTechniqueEnabled() and owner:Health() < owner:GetMaxHealth() then
		self:EmitSound(self.ReverseCurseSound)

		if CLIENT and IsFirstTimePredicted() then
			CreateParticleSystemNoEntity("blood_impact_red_01", owner:EyePos() - owner:GetUp() * 15)
		end
	end
end

--Deprecated
--I use this instead of timers, as it can support prediction
function SWEP:SetTimedEvent(name, time)
	self:SetNextEvent(CurTime() + time)
	self:SetEvent(name)
end

-- Adding hooks
