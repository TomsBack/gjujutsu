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
	[AbilityKey.Ability5] = "FireArrowStart",
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
	[AbilityKey.Ability5] = "FireArrowEnd",
	[AbilityKey.Ability6] = nil,
	[AbilityKey.Ability7] = nil,
	[AbilityKey.Ability8] = nil,
	[AbilityKey.Ultimate] = nil,
	[AbilityKey.Taunt] = nil,
	[AbilityKey.Primary] = nil,
	[AbilityKey.Secondary] = "Teleport",
	[AbilityKey.Block] = "EndBlock",
}

SWEP.DefaultHealth = 3000
SWEP.DefaultMaxHealth = 3000

SWEP.PrimaryCD = 0
SWEP.SecondaryCD = 3
SWEP.Ability3CD = 3
SWEP.Ability4CD = 15
SWEP.Ability5CD = 20
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
SWEP.DefaultHealthGain = 4

SWEP.HealthGain = 4
SWEP.CursedEnergyDrain = 1.5 -- Per tick

SWEP.DomainRange = 7000

SWEP.BrainRecover = true
SWEP.CanHealOthers = true

SWEP.HealthPerFinger = 1150
SWEP.EnergyPerFinger = 1500
SWEP.HealthGainPerFinger = 0.6 -- For reverse curse technique
SWEP.EnergyGainPerFinger = 0.01

SWEP.MaxFingers = 20

SWEP.DismantleAngle = 0.8
SWEP.DismantleRange = 2000
SWEP.CleaveRange = 150

SWEP.ClashPressScore = 2

SWEP.FireArrowVoice = Sound("sukuna/voice/fire_arrow.wav")

gebLib.ImportFile("includes/thinks.lua")
gebLib.ImportFile("includes/cinematics.lua")

function SWEP:SetupDataTables()
	self:DefaultDataTables()

	self:NetworkVar("Int", 0, "Fingers")

	self:NetworkVar("Bool", 0, "HoldingCleave")
	self:NetworkVar("Bool", 1, "HoldingFireArrow")

	self:NetworkVar("Entity", 0, "FireArrow")
	self:NetworkVar("Entity", 1, "MahoragaWheel")

	self:NetworkVarNotify( "Fingers", self.OnVarChanged)
end

function SWEP:OnVarChanged(name, old, new)
	if name ~= "Fingers" then return end

	self:UpdateFingerStats(new)

	hook.Run("gJujutsu_OnFingerUpdate", self, old, new)
end

function SWEP:Initialize()
	self:DefaultInitialize()

	self:SetCursedEnergy(self.DefaultCursedEnergy)
	self:SetMaxCursedEnergy(self.DefaultMaxCursedEnergy)
	self:SetCursedEnergyRegen(self.DefaultCursedEnergyRegen)

	self:SetFingers(1)
end

function SWEP:PostInitialize()
	self:DefaultPostInitialize()

	self:SetFingers(1)

	local owner = self:GetOwner()

	if SERVER and owner:IsValid() then
		owner:SetBodygroup(1, 0)

		local wheel = ents.Create("mahoraga_wheel")
		self:SetMahoragaWheel(wheel)
		wheel:SetOwner(owner)
		wheel:FollowBone(owner, owner:LookupBone("head"))
		wheel:SetPos(owner:EyePos() + owner:GetUp() * 10)
		wheel:Spawn()
	end
end

function SWEP:Deploy()
	self:DefaultDeploy()

	local owner = self:GetOwner()

	if SERVER then
		owner:SetMaxHealth(self.DefaultMaxHealth + (self.HealthPerFinger * self:GetFingers()))
	end
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

	self:ConVarsThink()
	self:MiscThink()
	self:ReverseTechniqueThink()
	self:StatsRegenThink()
	self:ClampStatsThink()
	self:EventThink()
	self:ReversedActionClearThink()
	self:DomainClearThink()
	self:BrainRecoverThink()
	self:HealOthersThink()
	-- self:FingerStatsThink()

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
				self:DismantleSlash(50 * (1 + self:GetFingers() / 3))
			end)
			nextSlash = nextSlash + 0.09
		end

		cd = cd * 3
	else 
		self:DismantleSlash(150 * (1 + self:GetFingers() / 3))
	end


	self:SetNextAbility3(CurTime() + cd)
end

function SWEP:DismantleSlash(damage)
	local owner = self:GetOwner()
	local ownerPos = owner:GetPos()
	local aimVector = owner:GetAimVector()

	local force = aimVector * 50000

	local damageInfo = DamageInfo()
	damageInfo:SetDamageType(5)
	if owner:IsValid() then damageInfo:SetAttacker(owner) end
	if self:IsValid() then damageInfo:SetInflictor(self) end
	damageInfo:SetDamage(damage)
	damageInfo:SetDamageForce(force)

	owner:gebLib_PlayAction("dismantle", 1.35)

	timer.Simple(0.3, function()
		if SERVER then
			owner:EmitSound(Sound("misc/cloth_whoosh_1.wav"))
			owner:EmitSound(Sound("sukuna/sfx/dismantle_slash.wav"))
		end

		owner:ViewPunch( Angle( -10, 0, 0 ) )

		owner:LagCompensation(true)
		for _, ent in ipairs(ents.FindInCone(ownerPos, aimVector, self.DismantleRange, self.DismantleAngle)) do
			if self.HitBlacklist[ent:GetClass()] then continue end
			if ent == self or ent == owner then continue end
			if ent:GetOwner() == owner then continue end
			if ent == self:GetDomain() then continue end
			
			local customDamageType = self.DamageExceptions[ent:GetClass()]
			
			if customDamageType ~= nil then
				damageInfo:SetDamageType(customDamageType)
			else
				damageInfo:SetDamageType(5)
			end
			
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
	end)
end
	
-- Ability4
function SWEP:Cleave()
	if CurTime() < self:GetNextAbility4() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability4Cost then return end

	local owner = self:GetOwner()
	local ownerPos = owner:GetPos()
	
	for k, ent in ipairs(ents.FindInSphere(ownerPos, self.CleaveRange)) do
		if self.HitBlacklist[ent:GetClass()] then continue end
		if not ent:gebLib_IsProp() and not ent:gebLib_IsPerson() then continue end
		if ent == self or ent == owner then continue end
		if ent:GetOwner() == owner then continue end
		if ent == self:GetDomain() then continue end

		if SERVER then
			local timerName = "Gjujutsu_Cleave" .. tostring(ent:EntIndex()) .. tostring(ent)

			timer.Create(timerName, 0.06, 20, function()
				if not ent:IsValid() then 
					timer.Remove(timerName) 
					return 
				end
	
				local force = VectorRand(-1, 1) * 100
				
				local damageInfo = DamageInfo()
				damageInfo:SetDamageType(5)
				if owner:IsValid() then damageInfo:SetAttacker(owner) end
				if self:IsValid() then damageInfo:SetInflictor(self) end
				damageInfo:SetDamageForce(force)
				damageInfo:SetDamage(100)
	
				local customDamageType = self.DamageExceptions[ent:GetClass()]
		
				if customDamageType ~= nil then
					damageInfo:SetDamageType(customDamageType)
				else
					damageInfo:SetDamageType(5)
				end

				local phys = ent:GetPhysicsObject()

				ent:SetVelocity(force)
				if phys:IsValid() then
					phys:SetVelocity(force)
				end

				ent:EmitSound(Sound("sukuna/sfx/dismantle_slash.wav"), 75, math.random(70, 150), 0.7, CHAN_STATIC)
		
				SuppressHostEvents(nil)
				ent:TakeDamageInfo(damageInfo)
				SuppressHostEvents(owner)
			end)
		end

		if CLIENT then
			local particle = CreateParticleSystem(ent, "cleave", PATTACH_ABSORIGIN_FOLLOW, 0)

			timer.Simple(1, function()
				if not particle:IsValid() then return end

				particle:StopEmission()
			end)
		end
	end
end

-- Ability5
function SWEP:FireArrowStart()
	if CurTime() < self:GetNextAbility5() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability5Cost.Min then return end
	self:SetBusy(true)
	self:SetHoldingFireArrow(true)

	print("Started holding fire arrow")

	self:EmitSound(self.FireArrowVoice)
	
	local owner = self:GetOwner()
	if SERVER then
		owner:EmitSound(Sound("sukuna/sfx/fire_arrow_start.wav"))
	end
	owner:gebLib_PlayAction("FireArrow", 1)

	timer.Simple(0.8, function()
		if not owner:IsValid() then return end
		if not self:IsValid() then return end
		if not self:GetHoldingFireArrow() then return end

		if SERVER then
			local arrow = ents.Create("fire_arrow")
			self:SetFireArrow(arrow)
			arrow:SetOwner(owner)
			arrow:Spawn()
		end
	end)

	timer.Simple(1.35, function()
		if not owner:IsValid() then return end
		if not self:IsValid() then return end
		if not self:GetHoldingFireArrow() then return end

		owner:gebLib_PauseAction()
	end)
	
	self.LastMoveType = owner:GetMoveType()
	owner:SetMoveType(MOVETYPE_NONE)
	owner:SetVelocity(-owner:GetVelocity())

	return true
end

function SWEP:FireArrowEnd()
	if not self:GetHoldingFireArrow() then return end
	local arrow = self:GetFireArrow()

	self:SetBusy(false)
	self:SetHoldingFireArrow(false)
	self:SetNextAbility5(CurTime() + self.Ability5CD)

	if not arrow:IsValid() then
		self:SetNextAbility5(CurTime() + 1)
	end

	local owner = self:GetOwner()

	if owner:IsValid() then
		owner:gebLib_ResumeAction(1)
		owner:SetVelocity(-owner:GetVelocity())
		owner:SetMoveType(self.LastMoveType)
	end

	print("Stopped holding fire arrow")

	if arrow:IsValid() then
		arrow:Release()
		self:SetFireArrow(NULL)
	end
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

function SWEP:StartBlock()
	self:DefaultStartBlock()
end

function SWEP:EndBlock()
	self:DefaultEndBlock()
end

-- Secondary ability

function SWEP:AddFinger()
	self:SetFingers(math.min(self:GetFingers() + 1, self.MaxFingers))
end

function SWEP:UpdateFingerStats(fingers)
	local owner = self:GetOwner()

	print("Updated Stats", fingers)

	self:SetMaxCursedEnergy(self.DefaultMaxCursedEnergy + (self.EnergyPerFinger * fingers))
	self:SetCursedEnergy(self:GetMaxCursedEnergy())
	self:SetCursedEnergyRegen(self.DefaultCursedEnergyRegen + (self.EnergyGainPerFinger * fingers))

	self.HealthGain = self.DefaultHealthGain + (self.HealthGainPerFinger * fingers)

	if SERVER and owner:IsValid() then
		owner:SetMaxHealth(self.DefaultMaxHealth + (self.HealthPerFinger * fingers))
		owner:SetHealth(owner:GetMaxHealth())
	end
end

-- Adding hooks
