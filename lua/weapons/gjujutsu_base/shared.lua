if SERVER then
	util.AddNetworkString("gJujutsu_cl_deploy")
	util.AddNetworkString("gJujutsu_cl_onBlock")
	util.AddNetworkString("gJujutsu_cl_onPerfectBlock")
end

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

SWEP.HitBlacklist = {
	["env_spritetrail"] = true,
	["purple_fragment"] = true,
	["class CLuaEffect"] = true,
	["gmod_hands"] = true,
	["gmod_tool"] = true,
	["gmod_camera"] = true,
	["class C_PhysPropClientside"] = true,
	["domain_floor"] = true,
	["func_button"] = true,
	["prop_door_rotating"] = true,
	["class C_BaseEntity"] = true,
	["entityflame"] = true,
	["trigger_soundscape"] = true,
	["info_player_start"] = true,
	["info_player_counterterrorist"] = true,
	["trigger_teleport"] = true,
	["info_teleport_destination"] = true,
	["func_brush"] = true,
	["func_areaportalwindow"] = true,
	["predicted_viewmodel"] = true,
	["physgun_beam"] = true,
	["env_sprite"] = true,
	["point_spotlight"] = true,
	["spotlight_end"] = true,
	["beam"] = true,
	["env_soundscape_triggerable"] = true,
	["phys_bone_follower"] = true,
	["path_track"] = true,
	["info_target"] = true,
	["ambient_generic"] = true,
	["lua_run"] = true,
	["point_hurt"] = true,
	["env_entity_dissolver"] = true,
	["info_ladder_dismount"] = true,
	["func_useableladder"] = true,
	["func_door"] = true,
	["func_areaportal"] = true,
	["water_lod_control"] = true,
	["env_tonemap_controller"] = true,
	["func_door_rotating"] = true,
	["info_ladder_dismount"] = true,
	["info_ladder_dismount"] = true,
	["info_ladder_dismount"] = true,
	["info_ladder_dismount"] = true,
}

SWEP.DamageExceptions = {
    ["npc_monk"] = DMG_GENERIC,
    ["npc_strider"] = DMG_GENERIC,
    ["npc_alyx"] = DMG_GENERIC,
    ["npc_barney"] = DMG_GENERIC,
    ["npc_mossman"] = DMG_GENERIC,
    ["npc_gman"] = DMG_GENERIC,
	["npc_rollermine"] = DMG_BLAST,
	["npc_antlionguard"] = DMG_GENERIC,
	["npc_vortigaunt"] = DMG_GENERIC,
	["VortigauntSlave"] = DMG_GENERIC,
	["npc_combinegunship"] = DMG_GENERIC,
	["npc_combinedropship"] = DMG_CRUSH,
	["npc_helicopter"] = DMG_AIRBOAT
}

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
	[AbilityKey.Block] = nil,
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
	[AbilityKey.Block] = nil,
}

SWEP.BlockCD = 2
SWEP.PrimaryCD = 0
SWEP.SecondaryCD = 0
SWEP.Ability3CD = 0
SWEP.Ability4CD = 0
SWEP.Ability5CD = 0
SWEP.Ability6CD = 0
SWEP.Ability7CD = 0
SWEP.Ability8CD = 0
SWEP.UltimateCD = 0
SWEP.TauntCD = 0

-- Cost is meant in cursed energy
SWEP.BlockCost = 0
SWEP.PrimaryCost = 0
SWEP.SecondaryCost = 0
SWEP.Ability3Cost = 0
SWEP.Ability4Cost = 0
SWEP.Ability5Cost = 0
SWEP.Ability6Cost = 0
SWEP.Ability7Cost = 0
SWEP.Ability8Cost = 0
SWEP.UltimateCost = 0
SWEP.TauntCost = 0

SWEP.Grade = Grade.NoGrade

SWEP.DefaultDamageMultiplier = 1
SWEP.DamageMultiplier = 1

SWEP.DefaultHealth = 1000
SWEP.DefaultMaxHealth = 1000

SWEP.BrainRecover = false
SWEP.BrainRecoverTimer = 60
SWEP.NextBrainRecoverTimer = 0
SWEP.BrainRecoverLimit = 5
SWEP.BrainRecoverDrain = 500
SWEP.BrainRecoverCD = 2

SWEP.CanHealOthers = false
SWEP.HealRange = 150

SWEP.DefaultHealthGain = 2 -- Per tick
SWEP.HealthGain = 2 -- Per tick
SWEP.ExtinguishDrain = 25

SWEP.DefaultCursedEnergy = 1000
SWEP.DefaultMaxCursedEnergy = 1000
SWEP.DefaultCursedEnergyRegen = 0.15 -- Per tick
SWEP.CursedEnergyDrain = 1.75 -- Per tick

SWEP.RunSpeed = 800
SWEP.WalkSpeed = 300
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

SWEP.PerfectBlockTime = 0.2 -- The player needs to press the block button in this time window in order to perfect block
SWEP.PerfectBlockMult = 0.05 -- 0.1 means the player takes only 10% of the original damage, 0.5 is 50%, so player takes 50%

SWEP.BlockMult = 0.5

SWEP.ReverseCursedParticle = NULL

SWEP.ReverseCurseSound = Sound("misc/reverse_curse_activate.wav")
SWEP.BlockStartSound = Sound("misc/cloth_whoosh_1.wav")
SWEP.BlockEndSound = Sound("misc/cloth_whoosh_1_reverse.wav")

SWEP.BrainRecoverConvar = GetConVar("gjujutsu_misc_brain_recover_limit")

gebLib.ImportFile("includes/thinks.lua")

gJujutsu_EntsBlacklist = {
	["ba_stand_rewritten"] = true,
}

function SWEP:DefaultDataTables()
	self:NetworkVar("Entity", 31, "Domain")

	self:NetworkVar("Bool", 26, "Block")
	self:NetworkVar("Bool", 27, "ClashStart")
	self:NetworkVar("Bool", 27, "DomainClash")
	self:NetworkVar("Bool", 28, "InCinematic")
	self:NetworkVar("Bool", 29, "Busy")
	self:NetworkVar("Bool", 30, "ReverseTechniqueEnabled")
	self:NetworkVar("Bool", 31, "BlockCamera")

	self:NetworkVar("Float", 14, "BrainRecoverCount")
	self:NetworkVar("Float", 15, "NextBlock")
	self:NetworkVar("Float", 16, "BlockStart")
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
	self:SetupDefaultValues(true)

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
	-- self:SetupModel() -- Runs two times otherwise
	self:SetupDefaultValues(true)

	self:SetHoldType(self.HoldType)

	self:EnableFlashlight(false)
end

function SWEP:DefaultDeploy()
	self:SetupModel()
	self:SetupDefaultValues()
	self:EnableFlashlight(false)

	if SERVER then
		net.Start("gJujutsu_cl_deploy")
		net.WriteEntity(self)
		net.Broadcast()
	end
end

function SWEP:DefaultHolster()
	self:RestoreOldValues()

	self:EnableFlashlight(true)
end

function SWEP:SetupDefaultValues(setHealth)
	self:SetBlockCamera(false)

	local owner = self:GetOwner()

	if not owner:IsValid() then return end
	
	if SERVER then
		owner:SetMaxHealth(self.DefaultMaxHealth)
	end

	if setHealth then
		owner:SetHealth(self.DefaultHealth)
	end

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

	if SERVER and game.SinglePlayer() then
		self:CallOnClient("SetupModel")
	end
	
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

function SWEP:SetGlobalCD(cdAmount, disableTechniques)
	if disableTechniques == nil then
		disableTechniques = true
	end

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

	if disableTechniques then
		self:DisableReverseCursed()
		
		if self:Gjujutsu_IsGojo() then
			self:SetInfinity(false)
		end
	end
end

function SWEP:ResetCds()
	self:SetPrimary(0)
	self:SetSecondary(0)
	self:SetNextAbility3(0)
	self:SetNextAbility4(0)
	self:SetNextAbility5(0)
	self:SetNextAbility6(0)
	self:SetNextAbility7(0)
	self:SetNextAbility8(0)
	self:SetNextUltimate(0)
	self:SetNextTaunt(0)
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

function SWEP:ReverseCursedEffect(alwaysPlay)
	if alwaysPlay == nil then
		alwaysPlay = false
	end
	local owner = self:GetOwner()

	if not owner:IsValid() then return end
	
	if self:GetReverseTechniqueEnabled() or alwaysPlay then
		self:EmitSound(self.ReverseCurseSound, 75, math.random(90, 110), 1, CHAN_STATIC)

		if CLIENT and IsFirstTimePredicted() then
			CreateParticleSystemNoEntity("blood_impact_red_01", owner:EyePos() - owner:GetUp() * 15)
		end
	end
end

function SWEP:DefaultStartBlock()
	if self:GetBlock() then return end
	if CurTime() < self:GetNextBlock() then return end

	self:SetBlockStart(CurTime())
	self:SetBlock(true)
	self:SetBusy(true)

	self:EmitSound(self.BlockStartSound)
	print("Blocking")

	hook.Run("gJujutsu_OnBlockStart", self)
end

function SWEP:DefaultEndBlock()
	if not self:GetBlock() then return end

	self:SetBlock(false)
	self:SetBusy(false)

	self:EmitSound(self.BlockEndSound)
	print("Blocking ended")

	hook.Run("gJujutsu_OnBlockEnd", self)

	self:SetNextBlock(CurTime() + self.BlockCD)
end

function SWEP:IsPerfectBlocking()
	local blockStart = self:GetBlockStart()

	return CurTime() - blockStart <= self.PerfectBlockTime
end

function SWEP:EnableReverseCursed()
	local owner = self:GetOwner()
	
	self:SetReverseTechniqueEnabled(true)

	if not owner:IsValid() then return end
	
	if owner:KeyDown(IN_SPEED) and self.BrainRecover then
		self:RecoverBrain()
	end
	
	if not self:GetReverseTechniqueEnabled() then return end

	self:ReverseCursedEffect()

	if CLIENT and owner:gebLib_PredictedOrDifferentPlayer() then
		print("Reverse cursed particles")
		self.ReverseCursedParticle = CreateParticleSystem(owner, "reverse_cursed", PATTACH_ABSORIGIN_FOLLOW, 0)
	end
end

function SWEP:RecoverBrain()
	local owner = self:GetOwner()

	self:RemoveCursedEnergy(self.BrainRecoverDrain)
	owner:SetHealth(owner:Health() - self.BrainRecoverDrain)
	self.NextBrainRecoverTimer = CurTime() + self.BrainRecoverTimer

	if self:GetBrainRecoverCount() < self.BrainRecoverLimit then	
		self:ResetCds()
		self:SetBrainRecoverCount(self:GetBrainRecoverCount() + 1)
	else
		if SERVER then
			owner:EmitSound(Sound("misc/brain_recover_fail.wav"), 75, math.random(90, 110), 1, CHAN_STATIC)
		end

		if CLIENT and owner:gebLib_PredictedOrDifferentPlayer() then
			CreateParticleSystem(owner, "blood_advisor_puncture_withdraw", PATTACH_ABSORIGIN_FOLLOW, 0, owner:GetUp() * 50)
		end
	end
	self:SetNextAbility8(CurTime() + self.BrainRecoverCD)

	print("Recovered techniques", self:GetBrainRecoverCount())

	self:ReverseCursedEffect(true)
	self:SetReverseTechniqueEnabled(false)
end

function SWEP:DisableReverseCursed()
	self:SetReverseTechniqueEnabled(false)
	local owner = self:GetOwner()

	if owner:KeyDown(IN_SPEED) and self.BrainRecover then
		self:RecoverBrain()
	end

	if CLIENT and self.ReverseCursedParticle:IsValid() then
		owner:StopParticlesNamed("reverse_cursed")
		self.ReverseCursedParticle:StopEmission()
	end
end

--Deprecated
--I use this instead of timers, as it can support prediction
function SWEP:SetTimedEvent(name, time)
	self:SetNextEvent(CurTime() + time)
	self:SetEvent(name)
end

-- Handling hooks

hook.Add("gJujutsu_OnPerfectBlock", "gJujutsu_PerfectBlockEffects", function(weapon, dmg)
	local owner = weapon:GetOwner()
	local pos = owner:GetPos()

	if CLIENT then
		if dmg >= 200 then
			CreateParticleSystemNoEntity("smoke_debris_ring", pos)
		end

		if dmg >= 500 then
			owner:EmitSound(Sound("misc/rock_hit.wav"))
			CreateParticleSystemNoEntity("debris_2", pos)
		end
	end
end)

hook.Add("gJujutsu_OnBlock", "test", function(weapon, dmg)
	print("block")
	print(weapon, dmg)
end)

-- Handling nets
if SERVER then return end

net.Receive("gJujutsu_cl_deploy", function()
	local weapon = net.ReadEntity()

	if game.SinglePlayer() then return end

	if weapon:IsValid() then
		weapon:Deploy()
	end
end)

net.Receive("gJujutsu_cl_onBlock", function()
	local weapon = net.ReadEntity()
	local damage = net.ReadInt(32)

	hook.Run("gJujutsu_OnBlock", weapon, damage)
end)

net.Receive("gJujutsu_cl_onPerfectBlock", function()
	local weapon = net.ReadEntity()
	local damage = net.ReadInt(32)

	hook.Run("gJujutsu_OnPerfectBlock", weapon, damage)
end)
