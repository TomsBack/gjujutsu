if SERVER then
	util.AddNetworkString("gJujutsu_cl_dismantle_slash")
	util.AddNetworkString("gJujutsu_cl_cleave_slash")
	util.AddNetworkString("gjujutsu_cl_slasheffect")
	util.AddNetworkString("SendSukunaStages")
end

SWEP.PrintName = "Sukuna"
SWEP.Author = "Tom"
SWEP.Instructions = "Limitless Techniques"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Category = "gJujutsu"
SWEP.Base = "gjujutsu_base"  

SWEP.ViewModel = ''
SWEP.WorldModel = 'models/chromeda/arrow.mdl'

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

SWEP.Model = Model("models/moon/ryomen_sukuna/Ryomen_Sukuna.mdl")

SWEP.Abilities = {
	[AbilityKey.Ability3] = "Dismantle",
	[AbilityKey.Ability4] = "Cleave",
	[AbilityKey.Ability5] = "FireArrowStart",
	[AbilityKey.Ability6] = "MahoragaWheelActivate",
	[AbilityKey.Ability7] = "WorldDissection",
	[AbilityKey.Ability8] = "ReverseTechnique",
	[AbilityKey.Ultimate] = "StartDomain",
	[AbilityKey.Taunt] = nil,
	[AbilityKey.Primary] = nil,
	[AbilityKey.Secondary] = "DomainSwitch",
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
	[AbilityKey.Secondary] = nil,
	[AbilityKey.Block] = "EndBlock",
}

SWEP.IsEvil = true

SWEP.DefaultHealth = 3000
SWEP.DefaultMaxHealth = 3000

SWEP.PrimaryCD = 0
SWEP.SecondaryCD = 3
SWEP.Ability3CD = 3
SWEP.Ability4CD = 12
SWEP.Ability5CD = 1
SWEP.Ability6CD = 0.5
SWEP.Ability7CD1 = 10
SWEP.Ability7CD2 = 120
SWEP.Ability8CD = 0.5
SWEP.UltimateCD = 1
SWEP.TauntCD = 0

SWEP.PrimaryCost = 0
SWEP.SecondaryCost = {Min = 25, Max = 250}
SWEP.Ability3Cost = 100
SWEP.Ability4Cost = 500
SWEP.Ability5Cost = {Min = 1000, Max = 3000}
SWEP.Ability6Cost = 0
SWEP.Ability7Cost1 = 1000
SWEP.Ability7Cost2 = 10000
SWEP.Ability8Cost = 0
SWEP.UltimateCost = 1
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

SWEP.AdaptationEnts = {}

SWEP.FireArrowVoice = Sound("sukuna/voice/fire_arrow.wav")

SWEP.MahoragaWheelConvar = GetConVar("gjujutsu_sukuna_mahoraga_wheel")
SWEP.MahoragaWheelFingerConVar = GetConVar("gjujutsu_sukuna_mahoraga_wheel_finger_req")
SWEP.FireArrowConvar = GetConVar("gjujutsu_sukuna_fire_arrow_finger_req")

gebLib.ImportFile("includes/thinks.lua")
gebLib.ImportFile("includes/cinematics.lua")

function SWEP:SetupDataTables()
	self:DefaultDataTables()
	self:NetworkVar( "Float", 2, "DimensionalSlashDelay" )
	self:NetworkVar( "Float", 3, "DimensionalSlashStateDelay" )

	self:NetworkVar("Int", 0, "Fingers")
	self:NetworkVar( "Int", 1, "DimensionalSlashState" )

	self:NetworkVar("Bool", 0, "HoldingCleave")
	self:NetworkVar("Bool", 1, "HoldingFireArrow")
	self:NetworkVar("Bool", 2, "DrawingFireArrow")
	self:NetworkVar("Bool", 3, "DomainSlashing")

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
	self:SetDimensionalSlashState(0)
end

function SWEP:PostInitialize()
	self:DefaultPostInitialize()

	self:SetFingers(1)

	local owner = self:GetOwner()

	if SERVER and owner:IsValid() then
		owner:SetBodygroup(1, 0)
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

	if SERVER and self:GetMahoragaWheel():IsValid() then
		self:GetMahoragaWheel():Remove()
	end

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
        self.ActivityTranslate[ACT_MP_STAND_IDLE] = owner:GetSequenceActivity(owner:LookupSequence("SukunIdle"))
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
	self.RepeatAnim = self.RepeatAnim or CurTime()
	if self:GetDrawingFireArrow() then
		if CurTime() > self.RepeatAnim then
			self.RepeatAnim = CurTime() + 8.5
			owner:gebLib_PlayAction("FugaCharge", 1)
		end
	end
	self.FixOtDalbaebov = self.FixOtDalbaebov or CurTime()
	if CurTime() > self.FixOtDalbaebov then
		self.FixOtDalbaebov = CurTime() + 0.1
		self:SetupModel()
	end
	self.DimensionalSlashDelay = self.DimensionalSlashDelay or CurTime()
	if CurTime() > self:GetDimensionalSlashDelay() then
		if self:GetDimensionalSlashState() != 0 then
			self:SetDimensionalSlashState(0)
		end
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
	self:SukunaConvarsThink()
end

function SWEP:PrimaryAttack()
	return false
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:OnRemove()
	if SERVER and self:GetMahoragaWheel():IsValid() then
		self:GetMahoragaWheel():Remove()
	end
end

-- Ability3
function SWEP:Dismantle()
	if CurTime() < self:GetNextAbility3() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability3Cost then return end

	local owner = self:GetOwner()

	local cd = self.Ability3CD

	owner:gebLib_PlayAction("dismantlebase", 1.7)

	local finalCost = self.Ability3Cost
	
	if owner:KeyDown(IN_SPEED) then
		local nextSlash = 0

		for i = 1, 7 do
			timer.Simple(nextSlash, function()
				self:DismantleSlash(50 * (1 + self:GetFingers() / 3))
			end)
			nextSlash = nextSlash + 0.1
		end

		finalCost = self.Ability3Cost * 3

		cd = cd * 3
	else 
		self:DismantleSlash(150 * (1 + self:GetFingers() / 3))
	end

	self:RemoveCursedEnergy(finalCost)
	self:SetNextAbility3(CurTime() + cd)
end

local angleKnockback = Angle(-5, 0, 0)
function SWEP:DismantleSlash(damage)
	if CLIENT then return end

	local owner = self:GetOwner()
	local ownerPos = owner:GetPos()
	local eyePos = owner:EyePos()
	local aimVector = owner:GetAimVector()

	local force = aimVector * 50000

	local damageInfo = DamageInfo()
	damageInfo:SetDamageType(5)
	if owner:IsValid() then damageInfo:SetAttacker(owner) end
	if self:IsValid() then damageInfo:SetInflictor(self) end
	damageInfo:SetDamage(damage)
	damageInfo:SetDamageForce(force)

	timer.Simple(0.35, function()
		owner:EmitSound(Sound("misc/cloth_whoosh_1.wav"))
		owner:EmitSound(Sound("sukuna/sfx/dismantle_slash.wav"))

		owner:ViewPunch(angleKnockback)

		owner:LagCompensation(true)
		for _, ent in ipairs(ents.FindInCone(eyePos - owner:GetForward() * 25, aimVector, self.DismantleRange, self.DismantleAngle)) do
			if gebLib_ClassBlacklist[ent:GetClass()] then continue end
			if ent == self or ent == owner then continue end
			if ent:GetOwner() == owner then continue end
			if ent == self:GetDomain() then continue end
			
			local customDamageType = self.DamageExceptions[ent:GetClass()]
			
			if customDamageType ~= nil then
				damageInfo:SetDamageType(customDamageType)
			else
				damageInfo:SetDamageType(5)
			end
			if owner:IsValid() then damageInfo:SetAttacker(owner) end
			if self:IsValid() then damageInfo:SetInflictor(self) end
			damageInfo:SetDamage(damage)
			damageInfo:SetDamageForce(force)

			SuppressHostEvents(nil)
			ent:TakeDamageInfo(damageInfo)
			SuppressHostEvents(owner)

			-- Nothing else worked sigh...
			net.Start("gJujutsu_cl_dismantle_slash")
			net.WriteEntity(ent)
			net.Broadcast()
			
			ent:EmitSound(Sound("sukuna/sfx/slash_prop_hit1.wav"))
			
			if ent:gebLib_IsPerson() then
				ent:EmitSound(Sound("sukuna/sfx/slash_body_hit" .. math.random(1, 2) .. ".wav"))
			end
			
			if ent:gebLib_IsProp() then
				ent:SetVelocity(force)
				
				local phys = ent:GetPhysicsObject()
				
				if phys:IsValid() then
					phys:SetVelocity(force)
				end
				
				SukunaPropCut(owner, ent, math.random(-40, 290))
			end
		end
		owner:LagCompensation(false)
	end)
end

-- FIXME: Fix cleave knockback
	
-- Ability4
function SWEP:Cleave()
	if CurTime() < self:GetNextAbility4() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability4Cost then return end

	local owner = self:GetOwner()
	local ownerPos = owner:GetPos()

	local finalDamage = 30 * (1 + self:GetFingers() / 3)
	
	for k, ent in ipairs(ents.FindInSphere(ownerPos, self.CleaveRange)) do
		if not ent:gebLib_IsUsableEntity() then continue end
		if not ent:gebLib_IsProp() and not ent:gebLib_IsPerson() then continue end
		if ent == self or ent == owner then continue end
		if ent:GetOwner() == owner then continue end
		if ent == self:GetDomain() then continue end

		local isPlayer = ent:IsPlayer()

		if SERVER then
			local timerName = "Gjujutsu_Cleave" .. tostring(ent:EntIndex()) .. tostring(ent)

			net.Start("gJujutsu_cl_cleave_slash")
			net.WriteEntity(ent)
			net.Broadcast()

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
				if ent:IsPlayer() and ent:GetActiveWeapon():IsValid() and ent:GetActiveWeapon():IsGjujutsuSwep() then
					damageInfo:SetDamage(finalDamage / 2)
				else
					damageInfo:SetDamage(finalDamage)
				end
	
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
				
				local hadFlag
				if isPlayer then 
					hadFlag = ent:IsEFlagSet( EFL_NO_DAMAGE_FORCES ) 
					ent:AddEFlags( EFL_NO_DAMAGE_FORCES ) 
				end
				//
				SuppressHostEvents(nil)
				ent:TakeDamageInfo(damageInfo)
				SuppressHostEvents(owner)
				//
				if hadFlag then 
					ent:AddEFlags( EFL_NO_DAMAGE_FORCES ) 
				end
			end)
		end
	end

	self:RemoveCursedEnergy(self.Ability4Cost)
	self:SetNextAbility4(CurTime() + self.Ability4CD)
end

-- Ability5
function SWEP:FireArrowStart()
	if self:GetFingers() < self.FireArrowConvar:GetInt() then return end
	if CurTime() < self:GetNextAbility5() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability5Cost.Min then return end
	self:SetBusy(true)
	self:SetHoldingFireArrow(true)
	self.RepeatAnim = CurTime()
	gebLib.PrintDebug("Started holding fire arrow")

	self:EmitSound(self.FireArrowVoice)
	
	local owner = self:GetOwner()
	if SERVER then
		owner:EmitSound(Sound("sukuna/sfx/fire_arrow_start.wav"))
	end
	owner:gebLib_PlayAction("Fuga", 1)

	timer.Simple(0.6, function()
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

	timer.Simple(3.65, function()
		if not owner:IsValid() then return end
		if not self:IsValid() then return end
		if not self:GetHoldingFireArrow() then return end
		self:SetDrawingFireArrow(true)
	end)
	
	self.LastMoveType = owner:GetMoveType()
	owner:SetMoveType(MOVETYPE_NONE)
	owner:SetVelocity(-owner:GetVelocity())

	return true
end

function SWEP:FireArrowEnd()
	if not self:GetHoldingFireArrow() then return end
	local arrow = self:GetFireArrow()
	self:SetDrawingFireArrow(false)
	self:SetBusy(false)
	self:SetHoldingFireArrow(false)
	self:SetNextAbility5(CurTime() + self.Ability5CD)
	self.RepeatAnim = CurTime()
	if not arrow:IsValid() then
		self:SetNextAbility5(CurTime() + 1)
	end
	local owner = self:GetOwner()

	if owner:IsValid() then
		owner:gebLib_PlayAction("FugaShoot", 1)
		owner:SetVelocity(-owner:GetVelocity())
		timer.Simple(1.7, function()
			if owner:IsValid() then
				owner:SetMoveType(self.LastMoveType)
			end
		end)
	end

	gebLib.PrintDebug("Stopped holding fire arrow")

	if arrow:IsValid() then
		arrow:Release()
		self:SetFireArrow(NULL)
	end
end

-- Ability6
function SWEP:MahoragaWheelActivate() 
	if not self.MahoragaWheelConvar:GetBool() then return end
	if self:GetFingers() < self.MahoragaWheelFingerConVar:GetInt() then return end
	if CurTime() < self:GetNextAbility6() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.Ability6Cost then return end
	self:SetNextAbility6(CurTime() + self.Ability6CD)

	local owner = self:GetOwner()

	if not owner:gebLib_ValidAndAlive() then return end

	if SERVER then
		if not self:GetMahoragaWheel():IsValid() then		
			local wheel = ents.Create("mahoraga_wheel")
			self:SetMahoragaWheel(wheel)
			wheel:SetOwner(owner)
			wheel:Spawn()
		else
			self:GetMahoragaWheel():Remove()
			self:SetMahoragaWheel(NULL)
		end
	end
end
local DimensionalSlashPhrases = {
	"Scale of the dragon",
    "Recoil",
    "Twin meteors"
}
-- Ability7
function SWEP:WorldDissection()
	if CurTime() < self:GetNextAbility7() then return end
	if CurTime() < self:GetDimensionalSlashStateDelay() then return end
	if self:GetBusy() then return end
	local owner = self:GetOwner()
	if not owner:gebLib_ValidAndAlive() then return end

	if !owner:KeyDown(IN_SPEED) then
		if self:GetCursedEnergy() < self.Ability7Cost1 then return end
		self:SetNextAbility7(CurTime() + self.Ability7CD1)
		self:RemoveCursedEnergy(self.Ability7Cost1)
		owner:EmitSound(Sound("misc/cloth_whoosh_1.wav"))
		owner:EmitSound(Sound("sukuna/sfx/dismantle_slash.wav"))
		self.touchedents = {}
		if SERVER then
			local targets = ents.FindInSphere(owner:GetPos(), 1000 )
			for _, v in ipairs(targets) do
				if (v:IsPlayer() or v:IsNPC() or v:GetClass() == "prop_physics") and v ~= owner and !self.touchedents[v] then
					self.touchedents[v] = true
					local direction = (v:GetPos() - owner:GetPos()):GetNormalized()
					local dotProduct = owner:GetAimVector():Dot(direction)
					local angle = math.deg(math.acos(dotProduct))
	
					if SERVER and angle <= 40 then
						local ownerPos = owner:GetPos()
						local eyePos = owner:EyePos()
						local aimVector = owner:GetAimVector()
					
						local force = aimVector * 50000
					
						local damageInfo = DamageInfo()
						damageInfo:SetDamageType(5)
						if owner:IsValid() then damageInfo:SetAttacker(owner) end
						if self:IsValid() then damageInfo:SetInflictor(self) end
						damageInfo:SetDamage(350 * (1 + self:GetFingers() / 3))
						damageInfo:SetDamageForce(force)
					
						owner:EmitSound(Sound("misc/cloth_whoosh_1.wav"))
						--owner:EmitSound(Sound("sukuna/sfx/dismantle_slash.wav"))
					
						owner:ViewPunch(angleKnockback)
					
						owner:LagCompensation(true)
						--for _, ent in ipairs(ents.FindInCone(eyePos - owner:GetForward() * 25, aimVector, self.DismantleRange, self.DismantleAngle)) do
							if gebLib_ClassBlacklist[v:GetClass()] then continue end
							if v == self or v == owner then continue end
							if v:GetOwner() == owner then continue end
							if v == self:GetDomain() then continue end
								
							local customDamageType = self.DamageExceptions[v:GetClass()]
								
							if customDamageType ~= nil then
								damageInfo:SetDamageType(customDamageType)
							else
								damageInfo:SetDamageType(5)
							end
							if owner:IsValid() then damageInfo:SetAttacker(owner) end
							if self:IsValid() then damageInfo:SetInflictor(self) end
							damageInfo:SetDamage(350 * (1 + self:GetFingers() / 3))
							damageInfo:SetDamageForce(force)
					
							SuppressHostEvents(nil)
							v:TakeDamageInfo(damageInfo)
							SuppressHostEvents(owner)
					
							gJujutsuSlash(owner, v, 0, math.random(6, 9))
								
							v:EmitSound(Sound("sukuna/sfx/slash_prop_hit1.wav"))
								
							if v:gebLib_IsPerson() then
								v:EmitSound(Sound("sukuna/sfx/slash_body_hit" .. math.random(1, 2) .. ".wav"))
							end
								
							if v:gebLib_IsProp() then
								v:SetVelocity(force)
									
								local phys = v:GetPhysicsObject()
									
								if phys:IsValid() then
									phys:SetVelocity(force)
								end
									
								SukunaPropCut(owner, v, -180)
							end
						--end
						owner:LagCompensation(false)
					end
				end
			end
		end
	else
		if self:GetCursedEnergy() < self.Ability7Cost2 then return end
		self:SetDimensionalSlashStateDelay(CurTime() + 0.65)
		if SERVER and self:GetDimensionalSlashState() < 3 then
			self:SetDimensionalSlashState(self:GetDimensionalSlashState() + 1)
			owner:EmitSound(Sound("sukuna/sfx/Dimensional Slash"..self:GetDimensionalSlashState()..".wav"))
			self:SetDimensionalSlashDelay(CurTime() + 1)
			owner:Say(DimensionalSlashPhrases[self:GetDimensionalSlashState()])
		elseif self:GetDimensionalSlashState() == 3 then
			self:SetNextAbility7(CurTime() + self.Ability7CD2)
			self:SetDimensionalSlashState(0)
			owner:EmitSound(Sound("sukuna/sfx/Dimensional Slash Final.wav"))
			self:RemoveCursedEnergy(self.Ability7Cost2)
			self.touchedents = {}
			if SERVER then
				local targets = ents.FindInSphere(owner:GetPos(), 7000 )
				for _, v in ipairs(targets) do
					if (v:IsPlayer() or v:IsNPC() or v:GetClass() == "prop_physics") and v ~= owner and !self.touchedents[v] then
						self.touchedents[v] = true
						local direction = (v:GetPos() - owner:GetPos()):GetNormalized()
						local dotProduct = owner:GetAimVector():Dot(direction)
						local angle = math.deg(math.acos(dotProduct))
		
						if SERVER and angle <= 40 then
							local ownerPos = owner:GetPos()
							local eyePos = owner:EyePos()
							local aimVector = owner:GetAimVector()
						
							local force = aimVector * 50000
						
							local damageInfo = DamageInfo()
							damageInfo:SetDamageType(5)
							if owner:IsValid() then damageInfo:SetAttacker(owner) end
							if self:IsValid() then damageInfo:SetInflictor(self) end
							damageInfo:SetDamage(1250 * (1 + self:GetFingers() / 3))
							damageInfo:SetDamageForce(force)
						
							owner:EmitSound(Sound("misc/cloth_whoosh_1.wav"))
							--owner:EmitSound(Sound("sukuna/sfx/dismantle_slash.wav"))
						
							owner:ViewPunch(angleKnockback)
						
							owner:LagCompensation(true)
							--for _, ent in ipairs(ents.FindInCone(eyePos - owner:GetForward() * 25, aimVector, self.DismantleRange, self.DismantleAngle)) do
								if gebLib_ClassBlacklist[v:GetClass()] then continue end
								if v == self or v == owner then continue end
								if v:GetOwner() == owner then continue end
								if v == self:GetDomain() then continue end
									
								local customDamageType = self.DamageExceptions[v:GetClass()]
									
								if customDamageType ~= nil then
									damageInfo:SetDamageType(customDamageType)
								else
									damageInfo:SetDamageType(5)
								end
								if owner:IsValid() then damageInfo:SetAttacker(owner) end
								if self:IsValid() then damageInfo:SetInflictor(self) end
								damageInfo:SetDamage(1250 * (1 + self:GetFingers() / 3))
								damageInfo:SetDamageForce(force)
						
								SuppressHostEvents(nil)
								v:TakeDamageInfo(damageInfo)
								SuppressHostEvents(owner)
						
								gJujutsuSlash(owner, v, 0, math.random(6, 9))
									
								v:EmitSound(Sound("sukuna/sfx/slash_prop_hit1.wav"))
									
								if v:gebLib_IsPerson() then
									v:EmitSound(Sound("sukuna/sfx/slash_body_hit" .. math.random(1, 2) .. ".wav"))
								end
									
								if v:gebLib_IsProp() then
									v:SetVelocity(force)
										
									local phys = v:GetPhysicsObject()
										
									if phys:IsValid() then
										phys:SetVelocity(force)
									end
										
									SukunaPropCut(owner, v, -180)
								end
							--end
							owner:LagCompensation(false)
						end
					end
				end
			end
		end
	end
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

	if CurTime() < self:GetNextUltimate() and not domain:IsValid() then return end
	if self:GetBusy() then return end
	if self:GetCursedEnergy() < self.UltimateCost and not domain:IsValid() then return end

	local owner = self:GetOwner()
	owner:gebLib_PlayAction("SukunaDomainStart", 2.5)
	timer.Simple(0.26, function()
		if IsValid(self) and IsValid(owner) then
			owner:gebLib_PauseAction()
		end
	end)
	if not self.DomainClashConvar:GetBool() then
		self:DomainExpansion()
		return
	end
	timer.Simple(1.1, function()
		if IsValid(self) and IsValid(owner) then
			self:WindEffect(200, 0.55)
			util.ScreenShake(owner:GetPos(), 15, 15, 1, 500, true)
		end
	end)

	if SERVER then
		owner:Freeze(true)
	end

	if SERVER then
		util.ScreenShake(owner:GetPos(), 10, 10, 1, 500, true)
		owner:EmitSound(Sound("sukuna/voice/sukuna_domain_starting.wav"))
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
				gebLib.PrintDebug("Close in to clash")

				local nearClashData = ply:Gjujutsu_GetDomainClashData()

				gebLib.PrintDebug(tostring(owner) .. " joined the clash of " .. tostring(nearClashData.Players[1]))

				table.insert(nearClashData.Players, owner)
				return
			end
		end

		gebLib.PrintDebug("Creating own clash")
		owner:CreateDomainClashTable()
	end

	self:SetDomainClash(true)
	self:SetClashStart(true)
end


local indicatorMat = Material("models/spawn_effect2")
-- Secondary ability
function SWEP:DomainSwitch()
	if CurTime() < self:GetSecondary() then return end
	if !self:GetDomain():IsValid() then return end
	local owner = self:GetOwner()
	local domain = self:GetDomain()
	if IsValid(domain) then
		domain:SlashController()
	end

	return true
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
		domain:SetPos(owner:GetPos() + aimAngles:Forward() * -475)
		domain:SetAngles(aimAngles)
		domain:Spawn()
		domain:Activate()
	end

	if SERVER and game.SinglePlayer() then
		self:CallOnClient("DomainExpansion")
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

function SWEP:AdaptedToInfinity()
	if not self:GetMahoragaWheel():IsValid() then return end
	local adaptedCount = 0

	for entClass, data in pairs(self.AdaptationEnts) do
		if entClass ~= "gjujutsu_gojo" then continue end

		for dmgType, adaptData in pairs(data) do
			if adaptedCount >= 2 then
				return true
			end

			if adaptData.Percentage >= 100 then
				adaptedCount = adaptedCount + 1
			end
		end
	end

	if adaptedCount >= 2 then
		return true
	end

	return false
end

function SWEP:AddFinger()
	self:SetFingers(math.min(self:GetFingers() + 1, self.MaxFingers))
end

function SWEP:UpdateFingerStats(fingers)
	local owner = self:GetOwner()

	self:SetMaxCursedEnergy(self.DefaultMaxCursedEnergy + (self.EnergyPerFinger * fingers))
	self:SetCursedEnergy(self:GetMaxCursedEnergy())
	self:SetCursedEnergyRegen(self.DefaultCursedEnergyRegen + (self.EnergyGainPerFinger * fingers))

	self.HealthGain = self.DefaultHealthGain + (self.HealthGainPerFinger * fingers)

	if SERVER and owner:IsValid() then
		owner:SetMaxHealth(self.DefaultMaxHealth + (self.HealthPerFinger * fingers))
		owner:SetHealth(owner:GetMaxHealth())
	end
end


function SWEP:DrawWorldModel()
	--self:DrawModel()
end


local screenMat = Material("models/limitless/matsdomainsukuna")

function SWEP:DomainExpansionCinematic()
	local ply = self:GetOwner()
	local owner = ply
	local ownerPos = owner:GetPos()
	local aimAngles = owner:GetAimVector():Angle()

	local weapon = self

	self:SetBusy(true)
	self:SetBlockCamera(true)
	self:SetInCinematic(true)
	
	if SERVER then
		owner:Freeze(true)
	end

	local camera = gebLib_Camera.New("Sukuna_Domain", ply, 60, 250)
	owner.gJujutsu_Camera = camera

	local copy = camera.Copy
	ply.gJujutsu_Copy = copy
	local plyPos = nil
	local headPos = nil
	local forw = nil

	if CLIENT then
		copy:SetSequence(owner:LookupSequence("SukunaDomainStart"))
		copy:SetCycle(1)
	end

	local caughtInDomain = false

	local localPlayer = NULL
	local localPlayerPos = NULL

	if CLIENT then
		localPlayer = LocalPlayer()
		localPlayerPos = localPlayer:GetPos()

		plyPos = copy:GetPos()
		headPos = plyPos + copy:GetUp() * 70
		forw = copy:GetForward()

		caughtInDomain = false
	end

	local fps = 21
	local animRate = 1 / fps
	local interval = CurTime() + animRate
	local currentFrame = 9

	local playedClap = false
	local playedGif = false
	local screenEffectPaused = true
	local playedTheme = false

	hook.Add("RenderScreenspaceEffects", tostring(self) .. "_SukunaHudEffect", function()
		if not localPlayer:gebLib_Alive() then hook.Remove("RenderScreenspaceEffects", tostring(self) .. "_SukunaHudEffect") return end
		if localPlayer ~= owner then return end
		if screenEffectPaused then return end

		local curTime = CurTime()

		render.SetMaterial(screenMat)
		if curTime > interval then
			interval = curTime + animRate
			currentFrame = currentFrame - 1

			screenMat:SetInt("$frame", currentFrame)
		end
		render.DrawScreenQuad()
	end)

	camera:SetThink(function()
		if not camera:IsValid() then camera:Stop() return end

		if SERVER and not weapon:GetDomain():IsValid() then
			camera:Stop()

			net.Start("gJujutsu_cl_clearCamera")
			net.WriteEntity(ply)
			net.Broadcast()
			return 
		end

		if camera.CurFrame > 69 and not playedClap then
			playedClap = true
			if SERVER then
				owner:EmitSound("sukuna/voice/sukuna_domain_ending.wav")
			end
			--if CLIENT then
				--owner:EmitSound(Sound("sukuna/sfx/clap.wav"))
			--end
		end

		if camera.CurFrame > 95 and not playedGif and screenEffectPaused then
			playedGif = true
			screenEffectPaused = false
		end

		if camera.CurFrame > 300 and not playedTheme then
			playedTheme = true

			--if CLIENT then
				--owner:EmitSound(Sound("sukuna/sfx/domain_theme.mp3"))
			--end
		end

		if camera.CurFrame > 125 and not screenEffectPaused then
			screenEffectPaused = true
		end

		if not weapon:IsValid() then return end

		local domain = weapon:GetDomain()

		if not domain:IsValid() then return end
    end)

	camera:SetEnd(function()
		hook.Remove("RenderScreenspaceEffects", tostring(self) .. "_SukunaHudEffect")

		if SERVER then
			owner:Freeze(false)
		end

		if self:IsValid() then
			self:SetBusy(false)
			self:SetBlockCamera(false)
			self:SetInCinematic(false)

			local domain = self:GetDomain()
	
			if domain:IsValid() then
				domain:SetSpawnTime(CurTime())

				domain:StartDomain()
			end
		end

		owner.gJujutsu_Camera = nil
    end)

	if SERVER then
		camera:Play()
	end

	if SERVER then return end
    
    local head = copy:LookupBone("ValveBiped.Bip01_Head1")
    local rightHand = copy:LookupBone("ValveBiped.Bip01_R_Hand")
    local headPos = copy:GetPos() + copy:GetUp() * 60

    local rotateStart = 0

    local scaleMin = 0
    local scaleMax = 1
    local speed = 3

    local firstStartPos = copy:GetPos() + copy:GetForward() * 15 + copy:GetUp() * 62.5 + copy:GetRight() * -0.5
    local zoomOutPos = firstStartPos + copy:GetForward() * 150

    camera:AddEvent(0, 250, function(ply, pos, ang, fov)
        local initialAng = ang
		ang = copy:EyeAngles()
        if camera.CurFrame >= 1 and camera	.CurFrame <= 150 then
            pos = LerpVector(camera:GetTime(1, 150), firstStartPos, firstStartPos)
        end
        if camera.CurFrame >= 150 and camera.CurFrame <= 250 then
            --ang:RotateAroundAxis(ang:Up(), Lerp(math.ease.OutExpo(camera:GetTime(250, 450)), 0, 0))
            pos = LerpVector(math.ease.InOutQuart(camera:GetTime(150, 190)), firstStartPos, zoomOutPos)
        end
        ang:RotateAroundAxis(ang:Up(), 180)

        /*if camera.CurFrame >= 700 and camera.CurFrame <= 1100 then
            if camera:FrameFirstTime(700) then
                rotateStart = SysTime()
            end

            pos = math.QuadraticBezier(math.ease.InOutQuart(math.min((SysTime() - rotateStart) / 2, 1)), zoomOutPos, headPos - copy:GetRight() * 90, headPos - copy:GetForward() * 100)
            ang = (headPos - pos):Angle()
        end*/

        /*if camera.CurFrame >= 1100 then
            local startPos = backPos + copy:GetForward() * 25 - copy:GetUp() * 40
            pos = LerpVector(math.ease.OutExpo(camera:GetTime(1100, 1150)), startPos, startPos - copy:GetForward() * 80 - copy:GetRight() * 70)
            ang:RotateAroundAxis(ang:Up(), 180)
            ang:RotateAroundAxis(ang:Up(), Lerp(math.ease.OutExpo(camera:GetTime(1100, 1150)), 0, -5))
        end*/
        return pos, ang
    end)
    
    if localPlayer == ply then
        camera:Play()
    else
        camera:Play(true)
    end
end
