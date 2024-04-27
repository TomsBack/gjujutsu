SWEP.PrintName = "Gojo"
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
SWEP.HoldType = "gojo"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Model = Model("models/gjujutsu/gojo/gojo.mdl")

SWEP.PurpleAnimation = false
SWEP.PurpleAnimationStart = 0
SWEP.PurpleBlue = NULL
SWEP.PurlpleRed = NULL
SWEP.PurplePosOffset = 55

SWEP.HollowPurpleOffset = 100

SWEP.Abilities = {
	[AbilityKey.Ability3] = "LapseBlue",
	[AbilityKey.Ability4] = "ReversalRed",
	[AbilityKey.Ability5] = "HollowPurple",
	[AbilityKey.Ability6] = "InfinityActivate",
	[AbilityKey.Ability7] = "SixEyesActivate",
	[AbilityKey.Ability8] = "ReverseTechnique",
	[AbilityKey.Ultimate] = "StartDomain",
	[AbilityKey.Taunt] = nil,
	[AbilityKey.Primary] = nil,
	[AbilityKey.Secondary] = "TeleportHold",
	[AbilityKey.Block] = "StartBlock",
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
	[AbilityKey.Block] = "EndBlock",
}

SWEP.DefaultHealth = 12000
SWEP.DefaultMaxHealth = 12000

SWEP.PrimaryCD = 0
SWEP.SecondaryCD = 3
SWEP.Ability3CD = 5
SWEP.Ability4CD = 8
SWEP.Ability5CD = 25
SWEP.Ability6CD = 0.5
SWEP.Ability7CD = 0.5
SWEP.Ability8CD = 0.5
SWEP.UltimateCD = 50
SWEP.TauntCD = 0

SWEP.PrimaryCost = 0
SWEP.SecondaryCost = {Min = 10, Max = 100}
SWEP.Ability3Cost = 100
SWEP.Ability4Cost = 250
SWEP.Ability5Cost = {Min = 500, Max = 1250}
SWEP.Ability6Cost = 25
SWEP.Ability7Cost = 0
SWEP.Ability8Cost = 0
SWEP.UltimateCost = 750
SWEP.TauntCost = 0

SWEP.BrainRecover = true
SWEP.BrainRecoverDrain = 250

SWEP.TeleportDistance = 3500
SWEP.TeleportIndicator = NULL

SWEP.InfinityRadius = 175
SWEP.InfinityEnts = {}
SWEP.FlightDrain = 0.2 -- Per tick

SWEP.DefaultCursedEnergy = 15000
SWEP.DefaultMaxCursedEnergy = 15000
SWEP.CursedEnergyDrain = 1.25

SWEP.SixEyesCursedEnergyDrainMult = 0.5
SWEP.SixEyesCursedEnergyRegen = 0.28
SWEP.SixEyesHealthGain = 11
SWEP.SixEyesDamageMultiplier = 2.6

SWEP.ClashPressScore = 1.95

SWEP.InfinityBlacklist = {
	["mahoraga_wheel"] = true,
}

SWEP.BlueActivateSound = Sound("gojo/sfx/blue_summon.mp3")
SWEP.TeleportSound = Sound("gjujutsu_kaisen/sfx/gojo/teleport.mp3")
SWEP.BlueSummonSound = Sound("gjujutsu_kaisen/sfx/gojo/hollow_deploy.wav") -- For hollow purple anim
SWEP.InfinityActivateSound = Sound("gojo/sfx/infinity_activate.wav")

SWEP.InfinityConvar = GetConVar("gjujutsu_gojo_infinity_enabled")

gebLib.ImportFile("includes/thinks.lua")
gebLib.ImportFile("includes/cinematics.lua")
gebLib.ImportFile("includes/hollow_purple.lua")

local unrestrictedTeleport = GetConVar("gjujutsu_gojo_unrestricted_teleport")
local detonatePurple = GetConVar("gjujutsu_gojo_detonate_purple")

function SWEP:SetupDataTables()
	self:DefaultDataTables()

	self:NetworkVar("Bool", 0, "SixEyes")
	self:NetworkVar("Bool", 1, "Infinity")
	self:NetworkVar("Bool", 2, "Awakened")
	self:NetworkVar("Bool", 3, "HoldingTeleport")
	self:NetworkVar("Bool", 4, "HoldingPurple")
	self:NetworkVar("Bool", 5, "Flying")

	self:NetworkVar("Entity", 0, "Blue")
	self:NetworkVar("Entity", 1, "Red")
	self:NetworkVar("Entity", 2, "HollowPurple")
	self:NetworkVar("Entity", 3, "PurpleBlue")
	self:NetworkVar("Entity", 4, "PurpleRed")
end

function SWEP:Initialize()
	self:DefaultInitialize()

	self:SetSixEyes(false)
	self:SetInfinity(false)

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
	self:DisableInfinityProps()
	return true
end

local actIndex = {
	["gojo"] = ACT_HL2MP_IDLE
}

function SWEP:SetWeaponHoldType(holdType)
	holdType = string.lower(holdType)
	local index = actIndex[holdType]
    local owner = self:GetOwner()

	if not owner:IsValid() then return end
    if holdType == "gojo" then
        self.ActivityTranslate = {}
        self.ActivityTranslate[ACT_MP_STAND_IDLE] = owner:GetSequenceActivity(owner:LookupSequence("gojo_idle"))
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
	self.FixOtDalbaebov = self.FixOtDalbaebov or CurTime()
	if CurTime() > self.FixOtDalbaebov then
		self.FixOtDalbaebov = CurTime() + 0.1
		self:SetupModel()
	end
	self:ConVarsThink()
	self:MiscThink()
	self:InfinityThink()
	self:ReverseTechniqueThink()
	self:StatsRegenThink()
	self:ClampStatsThink()
	self:EventThink()
	self:ReversedActionClearThink()
	self:TeleportIndicatorThink()
	self:DomainClearThink()
	self:FlightThink()
	self:BrainRecoverThink()
	self:GojoConvarsThink()
end

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:OnRemove()
	if CLIENT then
		if self.TeleportIndicator:IsValid() then
			self.TeleportIndicator:Remove()
		end
	end
end

-- Ability3
function SWEP:LapseBlue()
	if CurTime() < self:GetNextAbility3() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability3Cost then return end
	local owner = self:GetOwner()

	if not owner:KeyDown(IN_DUCK) then
		self:SetBusy(true)
		self:EmitSound(self.BlueActivateSound)
		
		self:BlueSpawn(owner:KeyDown(IN_SPEED))
	else
		if SERVER then
			local angles = owner:GetAngles()

			local blue = ents.Create("blue_projectile")
			blue:SetOwner(owner)
			blue:SetPos(owner:GetPos() + angles:Up() * 63 + angles:Forward() * 19)
			blue:SetFireVelocity(owner:GetAimVector())
			blue:Spawn()
		end

		self:SetNextAbility3(CurTime() + self.Ability3CD * 1.5)
	end
		
	self:RemoveCursedEnergy(self.Ability3Cost)
	return true
end

-- Ability4
function SWEP:ReversalRed()
	if CurTime() < self:GetNextAbility4() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability4Cost then return end
	local owner = self:GetOwner()

	self:SetBusy(true)

	self:RedSpawn(owner:KeyDown(IN_SPEED))
	owner:gebLib_PlayAction("gojo_red")

	timer.Create("reversal_red_key_pause" .. tostring(owner), 2, 1, function()
		if not self:IsValid() then return end
		if not owner:IsValid() then return end
		if not self:GetRed():IsValid() then return end

		owner:gebLib_PauseAction()
	end)
	return true
end

-- Ability5
function SWEP:HollowPurple()
	if not self:GetSixEyes() then return end
	if CurTime() < self:GetNextAbility5() and not detonatePurple:GetBool() then return end
	if self:GetBusy() and not detonatePurple:GetBool() then return end
	if self:GetCursedEnergy() < self.Ability5Cost.Min then return end
	if self:GetHoldingPurple() then return end

	local hollowPurple = self:GetHollowPurple()

	-- TODO: Fix hollow purple when explosion is turned off, only blue gets summoned
	if hollowPurple:IsValid() and hollowPurple:GetFired() then
		hollowPurple:Explode()
		return
	end

	self:SetHoldingPurple(true)

	self:HollowPurpleBegin()
	return true
end

-- Ability6
function SWEP:InfinityActivate()
	if not self.InfinityConvar:GetBool() then return end
	if CurTime() < self:GetNextAbility6() then return end
	if self:GetBusy() then return end
	if not self:GetInfinity() and self:GetCursedEnergy() < self.Ability6Cost then return end
	local owner = self:GetOwner()

	if owner:Gjujutsu_IsInDomain() then
		self:SetInfinity(false)
		return
	end

	self:SetNextAbility6(CurTime() + self.Ability6CD)

	self:SetInfinity(not self:GetInfinity())

	if self:GetInfinity() then
		self:EmitSound(self.InfinityActivateSound)
	end

	if not owner:IsValid() then return end
	
	if not self:GetInfinity() then
		self:DisableInfinityProps()
		self:DisableFlight()
	end

	return true
end

-- Ability7
function SWEP:SixEyesActivate() 
	if CurTime() < self:GetNextAbility7() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability7Cost then return end
	self:SetNextAbility7(CurTime() + self.Ability7CD)

	self:SetSixEyes(not self:GetSixEyes())

	local owner = self:GetOwner()

	if self:GetSixEyes() then
		owner:SetBodygroup(1, 1)
		
		if owner:PredictedOrDifferentPlayer() or game.SinglePlayer() then
			self:SixEyesCinematic()
		end

		if SERVER and game.SinglePlayer() then
			self:CallOnClient("SixEyesCinematic")
		end

		self.DamageMultiplier = self.SixEyesDamageMultiplier
		self.HealthGain = self.SixEyesHealthGain
		self.CursedEnergyDrainMult = self.SixEyesCursedEnergyDrainMult

		self:SetCursedEnergyRegen(self.SixEyesCursedEnergyRegen)
	else
		owner:SetBodygroup(1, 0)

		self.DamageMultiplier = self.DefaultDamageMultiplier
		self.HealthGain = self.DefaultHealthGain
		self.CursedEnergyDrainMult = self.CursedEnergyDrainMult

		self:SetCursedEnergyRegen(self.DefaultCursedEnergyRegen)
	end

	return true
end

-- Ability8
function SWEP:ReverseTechnique() 
	if CurTime() < self:GetNextAbility8() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability8Cost then return end
	self:SetNextAbility8(CurTime() + self.Ability8CD)

	local reverseCurseEnabled = self:GetReverseTechniqueEnabled()

	if reverseCurseEnabled then
		self:DisableReverseCursed()
	else
		self:EnableReverseCursed()
	end
	
	return true
end

-- Ultimate
function SWEP:StartDomain()
	if not self.DomainConvar:GetBool() then return end
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

	if not self:GetSixEyes() and not domain:IsValid() then return end
	if CurTime() < self:GetNextUltimate() and not domain:IsValid() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.UltimateCost and not domain:IsValid() then return end

	local owner = self:GetOwner()

	if not self.DomainClashConvar:GetBool() then
		self:DomainExpansion()
		return
	end

	self:WindEffect(500, 1.55)

	if SERVER then
		owner:Freeze(true)
	end

	if SERVER then
		util.ScreenShake(owner:GetPos(), 10, 10, 1, 500, true)
		owner:EmitSound(Sound("gojo/voice/domain_start.wav"))
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

				local nearClashData = ply:Gjujutsu_GetDomainClashData()

				gebLib.PrintDebug(tostring(owner) .. " joined the clash of " .. tostring(nearClashData.Players[1]))

				table.insert(nearClashData.Players, owner)
				return
			end
		end
		owner:CreateDomainClashTable()
	end

	self:SetDomainClash(true)
	self:SetClashStart(true)
end

function SWEP:DomainExpansion()
	local domain = self:GetDomain()

	local owner = self:GetOwner()

	if SERVER and game.SinglePlayer() then
		self:CallOnClient("DomainExpansion")
	end

	if SERVER then
		owner:Freeze(true)
	end

	self:SetBusy(true)
	self:SetDomainClash(false)
	self:SetClashStart(false)

	self:DomainExpansionCinematic()

	if SERVER then
		local domain = ents.Create("gojo_domain")
		self:SetDomain(domain)
		domain:SetDomainOwner(owner)
		domain:SetPos(owner:GetPos())
		domain:Spawn()
		domain:Activate()
	end

	self:RemoveCursedEnergy(self.UltimateCost)
	
	-- Cooldowns are managed in each domain
	return true
end

local indicatorMat = Material("models/spawn_effect2")
-- Secondary ability
function SWEP:TeleportHold()
	if CurTime() < self:GetSecondary() then return end
	if self:GetBusy() and not unrestrictedTeleport:GetBool() then return end
	if self:GetHoldingTeleport() then return end
	if self:GetDomain():IsValid() then return end
	local owner = self:GetOwner()

	if owner:Gjujutsu_IsInDomain() then return end

	if SERVER and game.SinglePlayer() then
		self:CallOnClient("CreateTeleportIndicator")
	end

	self:CreateTeleportIndicator()
	
	self:SetHoldingTeleport(true)
	self:SetBusy(true)

	return true
end

function SWEP:CreateTeleportIndicator()
	if SERVER then return end
	
	if IsFirstTimePredicted() or game.SinglePlayer() then
		local owner = self:GetOwner()

		local angles = owner:GetAngles()
		angles.x = 0

		local indicator = ClientsideModel(Model("models/gjujutsu/gojo/gojo.mdl"))
		indicator:SetMaterial("models/spawn_effect2")
		indicator:SetSequence(owner:GetSequence())
		indicator:SetAngles(angles)
		indicator.RenderOverride = function(self)
			cam.IgnoreZ(true)
				render.SetBlend(0.75)
					self:DrawModel()
				render.SetBlend(1)
			cam.IgnoreZ(false)
		end

		self.TeleportIndicator = indicator
	end
end

function SWEP:RemoveTeleportIndicator()
	if SERVER then return end
	local owner = self:GetOwner()

	if LocalPlayer() == owner then
		owner:ScreenFade(SCREENFADE.PURGE, color_white, 0.01, 0.01)

		local indicator = self.TeleportIndicator
	
		if indicator and indicator:IsValid() then
			indicator:Remove()
		end
	end
end

function SWEP:Teleport()
	if CurTime() < self:GetSecondary() then return end
	if not self:GetHoldingTeleport() then return end

	self:SetBusy(false)
	self:SetHoldingTeleport(false)

	local owner = self:GetOwner()

	if not owner:IsValid() then return end
	if owner:InVehicle() then return end
	if self:GetCursedEnergy() < self.SecondaryCost.Min then return end

	local startPos = owner:EyePos()

	local traceData = {
		start = startPos,
		endpos = startPos + owner:GetAimVector() * self.TeleportDistance,
		filter = owner,
		mask = MASK_NPCWORLDSTATIC
	}

	local tr = util.TraceLine(traceData)
	
	local teleportPos = owner:gebLib_FindEmptyPosition(tr.HitPos, 500, 2, owner)
	owner:SetPos(teleportPos)
	self:EmitSound(self.TeleportSound)

	local finalCost = math.Remap(math.max(startPos:Distance(tr.HitPos), 0), 0, self.TeleportDistance, self.SecondaryCost.Min, self.SecondaryCost.Max)
	self:RemoveCursedEnergy(finalCost)

	if SERVER and game.SinglePlayer() then
		self:CallOnClient("RemoveTeleportIndicator")
	end

	self:RemoveTeleportIndicator()

	self:SetSecondary(CurTime() + self.SecondaryCD)
end

function SWEP:DisableInfinityProps()
	local owner = self:GetOwner()

	if not owner:IsValid() then return end

	local ownerPos = owner:GetPos()

	for ent, _ in pairs(self.InfinityEnts) do
		self:RemoveInfinityEffect(ent)
	end

	self.InfinityEnts = {}
end

local vector_origin = vector_origin
function SWEP:AddInfinityEffect(ent)
	if not ent:IsValid() then return end
	
	ent.gJujutsu_InfinityEffect = true
	ent.gJujutsu_OldMoveType = ent:GetMoveType()
	
	ent:SetMoveType(MOVETYPE_NONE)
	ent:SetVelocity(vector_origin)
	if not ent:IsNPC() then
		ent:AddEFlags(EFL_NO_THINK_FUNCTION)
	end

	local phys = ent:GetPhysicsObject()
	
	if phys:IsValid() then
		ent.gJujutsu_OldGravity = phys:IsGravityEnabled()
		phys:SetVelocityInstantaneous(vector_origin)
		phys:SetAngleVelocityInstantaneous(vector_origin)
		phys:EnableGravity(false)
	end
end

function SWEP:RemoveInfinityEffect(ent)
	if not ent:IsValid() then return end
	if not ent.gJujutsu_InfinityEffect then return end

	local oldPos = ent:GetPos()

	ent.gJujutsu_InfinityEffect = false

	if ent.gJujutsu_OldMoveType ~= nil then
		ent:SetMoveType(ent.gJujutsu_OldMoveType)
	end

	if not ent:IsNPC() then
		ent:RemoveEFlags(EFL_NO_THINK_FUNCTION)
	end

	local phys = ent:GetPhysicsObject()
	
	if phys:IsValid() then
		phys:EnableGravity(ent.gJujutsu_OldGravity)
		phys:Wake()
		phys:SetVelocityInstantaneous(vector_origin)
		phys:SetAngleVelocityInstantaneous(vector_origin)
	end
	ent:SetVelocity(vector_origin)

	ent:SetPos(oldPos)

	self.InfinityEnts[ent] = nil
end

function SWEP:RedSpawn(projectileMode)
	local owner = self:GetOwner()
	
	if SERVER then
		local red = ents.Create("reversal_red")
		red:SetOwner(owner)
		self:SetRed(red)
		red:SetProjectileMode(projectileMode)
		red:Spawn()
	end
end

function SWEP:HollowPurpleFire()
	-- if not self:GetHollowPurple():IsValid() then return end
	if CurTime() < self:GetNextAbility5() then return end
	if not self:GetHoldingPurple() then return end
	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()
	local hollowPurple = self:GetHollowPurple()

	self:SetHoldingPurple(false)
	
	if not hollowPurple:IsValid() then return end

	self:SetBusy(false)

	if SERVER then
		if not hollowPurple:GetFullOutput() then
			owner:EmitSound(Sound("gjujutsu_kaisen/gojo/voice/purple_voice_0".. math.random(1, 2) ..".wav"))
			hollowPurple:EmitSound(Sound("gjujutsu_kaisen/sfx/gojo/hollow_purple_fire.wav"))
		end

		if hollowPurple:GetFullOutput() then
			owner:EmitSound(Sound("gjujutsu_kaisen/gojo/voice/purple_voice_02.wav"))

			timer.Simple(0.8, function()
				if not owner:IsValid() then return end

				local effectData = EffectData()
				effectData:SetEntity(owner)
				effectData:SetOrigin(owner:EyePos() + owner:GetForward() * 50)
				util.Effect("vm_distort", effectData, true, true)
				
				hollowPurple:EmitSound(Sound("gjujutsu_kaisen/sfx/gojo/hollow_purple_fire.wav"))
				owner:EmitSound(Sound("gjujutsu_kaisen/sfx/gojo/hollow_ost.mp3"))
			end)
		end
	end

	if not hollowPurple:GetFullOutput() then
		self:SetTimedEvent("FireHollowPurple", 1)
		owner:gebLib_ResumeAction(1.75)
	end

	if hollowPurple:GetFullOutput() then
		self:SetTimedEvent("FireHollowPurple", 1.75)
		owner:gebLib_ResumeAction(1.25)
	end
end

function SWEP:RedFire()
	if not self:GetRed():IsValid() then return end
	if CurTime() < self:GetNextAbility4() then return end

	self:SetBusy(false)
	local red = self:GetRed()

	if not red:IsValid() then return end
	if not red.Initialized then return end
	
	self:SetBusy(false)
	red:FireOff()

	local redCost = math.Remap(red:GetHoldTime(), 0, red.MaxCharge, red.Cost.Min, red.Cost.Max)

	if not red:GetReady() then
		self:SetNextAbility4(CurTime() + self.Ability4CD / 10)
		self:RemoveCursedEnergy(redCost / 10)
		return
	end

	self:RemoveCursedEnergy(redCost)
	self:SetNextAbility4(CurTime() + self.Ability4CD)
end

function SWEP:BlueSpawn(aroundMode)
	if SERVER then
		local blue = ents.Create("lapse_blue")
		blue:SetOwner(self:GetOwner())
		self:SetBlue(blue)
		blue:SetAroundMode(aroundMode)
		blue:Spawn()
	end
end

function SWEP:BlueRemove()
	if not self:GetBlue():IsValid() then return end
	if CurTime() < self:GetNextAbility3() then return end
	self:SetNextAbility3(CurTime() + self.Ability3CD)
	self:SetBusy(false)

	local blue = self:GetBlue()
	
	if SERVER and blue:IsValid() then
		blue:Remove()
	end
end

function SWEP:DisableFlight()
	local owner = self:GetOwner()

	if not owner:IsValid() then return end

	self:SetFlying(false)
	owner:SetMoveType(MOVETYPE_WALK)
end

function SWEP:StartBlock()
	self:DefaultStartBlock()
end

function SWEP:EndBlock()
	self:DefaultEndBlock()
end

-- Adding hooks
