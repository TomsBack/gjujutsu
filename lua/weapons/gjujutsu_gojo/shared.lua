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

SWEP.DefaultHealth = 10000
SWEP.DefaultMaxHealth = 10000

SWEP.PrimaryCD = 0
SWEP.SecondaryCD = 3
SWEP.Ability3CD = 5
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

SWEP.TeleportDistance = 3000
SWEP.TeleportIndicator = NULL

SWEP.InfinityRadius = 175
SWEP.FlightDrain = 0.5 -- Per tick

SWEP.DefaultCursedEnergy = 8000
SWEP.DefaultMaxCursedEnergy = 8000

SWEP.SixEyesMaxCursedEnergy = 12000
SWEP.SixEyesCursedEnergyRegen = 0.25
SWEP.SixEyesHealthGain = 6
SWEP.SixEyesDamageMultiplier = 2

SWEP.ClashPressScore = 1.75

SWEP.BlueActivateSound = Sound("gjujutsu_kaisen/sfx/gojo/amplification_bluev2.mp3")
SWEP.TeleportSound = Sound("gjujutsu_kaisen/sfx/gojo/teleport.mp3")
SWEP.BlueSummonSound = Sound("gjujutsu_kaisen/sfx/gojo/hollow_deploy.wav") -- For hollow purple anim
SWEP.InfinityActivateSound = Sound("gojo/sfx/infinity_activate.wav")

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

	local owner = self:GetOwner()

	if owner:IsValid() then
		owner.gJujutsu_OldVelocity = owner:GetVelocity()
	end

	self:InfinityThink()
	self:ReverseTechniqueThink()
	self:StatsRegenThink()
	self:ClampStatsThink()
	self:EventThink()
	self:ReversedActionClearThink()
	self:TeleportIndicatorThink()
	self:DomainClearThink()
	self:FlightThink()

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

	self:SetBusy(true)
	self:EmitSound(self.BlueActivateSound)

	self:BlueSpawn(owner:KeyDown(IN_SPEED))
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
	if CurTime() < self:GetNextAbility6() then return end
	if self:GetBusy() then return end
	if not self:GetInfinity() and self:GetCursedEnergy() < self.Ability6Cost then return end
	self:SetNextAbility6(CurTime() + self.Ability6CD)

	self:SetInfinity(not self:GetInfinity())

	if self:GetInfinity() then
		self:EmitSound(self.InfinityActivateSound)
	end

	local owner = self:GetOwner()

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
		
		if owner:PredictedOrDifferentPlayer() then
			self:SixEyesCinematic()
		end

		self.DamageMultiplier = self.SixEyesDamageMultiplier
		self.HealthGain = self.SixEyesHealthGain

		self:SetMaxCursedEnergy(self.SixEyesMaxCursedEnergy)
		self:SetCursedEnergyRegen(self.SixEyesCursedEnergyRegen)
		
		if self:GetCursedEnergy() >= self.DefaultMaxCursedEnergy then
			self:SetCursedEnergy(self.SixEyesMaxCursedEnergy)
		end
	else
		owner:SetBodygroup(1, 0)

		self.DamageMultiplier = self.DefaultDamageMultiplier
		self.HealthGain = self.DefaultHealthGain

		self:SetMaxCursedEnergy(self.DefaultMaxCursedEnergy)
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

	if not self:GetSixEyes() and not domain:IsValid() then return end
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
	if self:GetDomain():IsValid() then return end

	self:SetHoldingTeleport(true)
	self:SetBusy(true)

	local owner = self:GetOwner()

	if CLIENT and IsFirstTimePredicted() then
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

	return true
end

function SWEP:Teleport()
	if CurTime() < self:GetSecondary() then return end
	if not self:GetHoldingTeleport() then return end

	self:SetBusy(false)
	self:SetHoldingTeleport(false)

	local owner = self:GetOwner()

	if not owner:IsValid() then return end
	if owner:InVehicle() then return end
	if owner:Gjujutsu_IsInDomain() then return end
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

	if CLIENT and LocalPlayer() == owner then
		owner:ScreenFade(SCREENFADE.PURGE, color_white, 0.01, 0.01)

		local indicator = self.TeleportIndicator
	
		if indicator and indicator:IsValid() then
			indicator:Remove()
		end
	end

	self:SetSecondary(CurTime() + self.SecondaryCD)
end

function SWEP:DisableInfinityProps()
	local owner = self:GetOwner()

	if not owner:IsValid() then return end

	local ownerPos = owner:GetPos()

	for _, ent in ents.Pairs() do
		if not ent:IsValid() then continue end
		if ent:IsPlayer() or ent:IsNextBot() then continue end
		local distance = ownerPos:Distance(ent:GetPos())
		local phys = ent:GetPhysicsObject()

		if distance <= self.InfinityRadius and ent.gJujutsu_InfinityEffect then
			ent.gJujutsu_InfinityEffect = false

			ent:SetMoveType(ent.gJujutsu_OldMoveType)

			if not ent:IsNPC() then
				ent:RemoveEFlags(EFL_NO_THINK_FUNCTION)
			end

			if phys:IsValid() then
				phys:EnableGravity(ent.gJujutsu_OldGravity)
				phys:Wake()
			end
			continue
		end
	end
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
	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()
	local hollowPurple = self:GetHollowPurple()

	self:SetHoldingPurple(false)
	
	if not hollowPurple:IsValid() then return end

	print("Stopped holding purple")

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

-- Adding hooks
