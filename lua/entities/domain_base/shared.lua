AddCSLuaFile()

ENT.PrintName = "Domain Expansion Base"
ENT.Author = "Tom" 
ENT.Contact = "Steam"
ENT.Purpose = "Base for all other domain expansions to inherit from"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.Category = "Domain Expansions"

ENT.DisableDuplicator = true
ENT.DoNotDuplicate = true
ENT.PhysgunDisabled = true

ENT.AutomaticFrameAdvance = true
ENT.RenderGroup	= RENDERGROUP_BOTH

ENT.DomainBlacklist = {
	["domain_base"] = true,
	["domain_barrier"] = true,
}

ENT.Children = {}

ENT.DomainModel = Model("models/gjujutsu/domain_barrier.mdl") -- Default model for barrier domains
ENT.DomainType = DomainType.Barrier
ENT.DomainBreakSound = Sound("gjujutsu_kaisen/sfx/domain_expansion/Domain_Breaking.wav")
ENT.BarrierMaterial = "phoenix_storms/black_chrome"

ENT.DefaultHealth = 15000
ENT.Range = 1500 -- 1 hammer unit is roughly 2cm

ENT.Initialized = false; -- Gmod has a bug, where sometimes entities do not run the initialization function
ENT.PostInitialized = false;

ENT.LifeTime = 30

ENT.DamageSoundTime = 3
ENT.NextDamageSound = 0

ENT.ResetStatesTime = 0.25 -- Time between each state reset, as we don't need to run something every frame/tick
ENT.NextResetStates = 0

ENT.DamageMaterial1 = nil
ENT.DamageTreshold1 = ENT.DefaultHealth / 2

ENT.DamageMaterial2 = nil
ENT.DamageTreshold2 = ENT.DefaultHealth / 5

ENT.DefaultScale = 5 -- Final scale of the model
ENT.ScaleTime = 1 -- Time it takes the model to scale to full size
ENT.ScaleFinished = false

ENT.PredictedThinkName = ""

ENT.EntsInDomain = {}

ENT.DomainBlacklist = {
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
}

ENT.DomainBaseBlacklist = {
	["domain_base"] = true
}

ENT.EnergyDrain = 1 -- How much cursed energy it drains per tick

function ENT:DefaultDataTables()
	self:NetworkVar("String", 0, "Event")

	self:NetworkVar("Float", 0, "NextEvent")
	self:NetworkVar("Float", 1, "SpawnTime")

	self:NetworkVar("Entity", 0, "DomainOwner") -- We cannot use self:GetOwner() as it disables collision with the barrier
	self:NetworkVar("Entity", 1, "DomainFloor")

	self:NetworkVar("Bool", 0, "DomainReady")

	self:NetworkVar("Int", 0, "DomainType")
end

function ENT:DefaultInitialize()
	self:SetSpawnTime(CurTime())

	hook.Run("gJujutsu_DomainStart", self)
	gJujutsuDomains[self:GetDomainOwner()] = self

	self.DamageTreshold1 = self.DefaultHealth / 2
	self.DamageTreshold2 = self.DefaultHealth / 5

	self:SetHealth(self.DefaultHealth)
	
	self:SetModel(self.DomainModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:DrawShadow(false)
	self:SetDomainType(self.DomainType)
	self:SetNoDraw(true)

	if CLIENT then
		self:SetPredictable(true)
	end

	if SERVER then
		self:SetLagCompensated(true)
	end

	if (self:GetDomainType() == DomainType.Barrier) then
		local owner = self:GetDomainOwner()

		self:SetMaterial(self.BarrierMaterial)
		self:SetModelScale(self.DefaultScale, 0)

		-- Creating domain floor
		if SERVER then
			local domainFloor = ents.Create("domain_floor")
			self:SetDomainFloor(domainFloor)
			domainFloor:SetOwner(self)
			domainFloor:SetPos(owner:GetPos() - owner:GetUp() * 12)
			domainFloor:Spawn()
		end
	end
	
	local phys = self:GetPhysicsObject()
	
	if phys:IsValid() then
		phys:AddGameFlag(bit.bor(FVPHYSICS_NO_PLAYER_PICKUP, FVPHYSICS_NO_SELF_COLLISIONS, FVPHYSICS_NO_NPC_IMPACT_DMG, FVPHYSICS_NO_IMPACT_DMG, FVPHYSICS_CONSTRAINT_STATIC))
		phys:EnableMotion(false)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
	end
	
	local predictedThink = "DomainExpansion" .. tostring(self:GetDomainOwner())
	self.PredictedThinkName = predictedThink

	hook.Add("FinishMove", predictedThink, function(ply, mv)
		self:PredictedThink(ply, mv)
	end)
end

function ENT:DefaultPredictedThink(ply, mv)
	self:LifeTimeThink()
	self:CheckEntsInDomain()
	self:OwnerDiedThink()
	self:DamageMaterialThink()
	self:ResetDefaultsThink()
	self:EventThink()
	self:DefaultThink()
end

function ENT:PredictedThink(ply, mv)
	if not self:IsValid() then 
		hook.Remove("FinishMove", self.PredictedThinkName)
		return
	end

	self:DefaultPredictedThink(ply, mv)
end

function ENT:DefaultThink()
	if not self.ScaleFinished and CurTime() - self:GetSpawnTime() > self.ScaleTime then
		self.ScaleFinished = true
		self:Activate()
		local phys = self:GetPhysicsObject()

		if phys:IsValid() then
			phys:EnableMotion(false)
			phys:EnableGravity(false)
		end
	end
end

function ENT:LifeTimeThink()
	if CurTime() - self:GetSpawnTime() > self.LifeTime then
		if SERVER then
			self:Remove()
		end
	end
end

function ENT:OwnerDiedThink()
	local owner = self:GetDomainOwner()

	if not owner:IsValid() then
		self:OnRemove()
		return
	end

	if owner:Health() <= 0 then
		self:OnRemove()
		return
	end
end

function ENT:EventThink()
	if CurTime() > self:GetNextEvent() and self:GetNextEvent() ~= 0 then
        local event = self:GetEvent()
        self:SetNextEvent(0)
        self[event](self)
    end
end

function ENT:ResetDefaultsThink()
	if CurTime() < self.NextResetStates then return end

	self:RemoveAllDecals()

	self.NextResetStates = CurTime() + self.ResetStatesTime
end 

function ENT:DamageMaterialThink()
	local currentHealth = self:Health()

	if DomainType == DomainType.Barrier then
		-- Need to go from the lowest damage threshold
		if self.DamageMaterial2 and currentHealth < self.DamageTreshold2 then
			self:SetMaterial(self.DamageMaterial2)
			return
		end
		
		if self.DamageMaterial1 and currentHealth < self.DamageTreshold1 then
			self:SetMaterial(self.DamageMaterial1)
			return
		end
	end
end

function ENT:DrainEnergyThink()
	if not self:GetDomainReady() then return end

	local owner = self:GetDomainOwner()

	if not owner:IsValid() then return end
	local weapon = owner:GetActiveWeapon()

	if weapon:IsValid() then
		weapon:RemoveCursedEnergy(self.EnergyDrain)
	end
end

function ENT:CheckEntsInDomain()
	local oldEnts = self.EntsInDomain
	local newEnts = {}

	for _, ent in ents.Pairs() do
		if not ent:IsValid() then continue end
		if self.Children[ent] then continue end
		if ent == self then continue end
		if self.DomainBlacklist[ent:GetClass()] then continue end
		if self.DomainBaseBlacklist[ent.Base] then continue end
		if not ent:IsSolid() and not ent:Gjujutsu_IsAbility() then continue end
		if ent:IsWeapon() then continue end

		if (self:IsInDomain(ent, false)) then
			newEnts[ent] = true
		end
	end

	-- Run custom hooks based on ent's state
	for oldEnt, _ in pairs(oldEnts) do
		if not oldEnt:IsValid() then continue end

		if not newEnts[oldEnt] then
			hook.Run("gJujutsu_EntLeftDomain", self, oldEnt)
		end
	end

	-- Run custom hooks based on ent's state
	for newEnt, _ in pairs(newEnts) do
		if not newEnt:IsValid() then continue end

		if not oldEnts[newEnt] then
			hook.Run("gJujutsu_EntEnteredDomain", self, newEnt)
		end
	end

	self.EntsInDomain = newEnts
end

hook.Add("gJujutsu_EntLeftDomain", "test", function(domain, ent)
	print(tostring(ent) .. " Left domain: " .. tostring(domain) .. " Solid: " .. tostring(ent:IsSolid()))
end)

hook.Add("gJujutsu_EntEnteredDomain", "test", function(domain, ent)
	print(tostring(ent) .. " Entered domain: " .. tostring(domain) .. " Solid: " .. tostring(ent:IsSolid()))
end)

--I use this instead of timers, as it can support prediction
function ENT:SetTimedEvent(name, time)
	self:SetNextEvent(CurTime() + time)
	self:SetEvent(name)
end

function ENT:DefaultStartDomain()
	self:SetSpawnTime(CurTime())
	self:SetDomainReady(true)
	self:SetNoDraw(false)

	if not self:GetDomainType() == DomainType.Barrier then return end
	if not self:GetDomainOwner():IsValid() then return end

	self:CheckEntsInDomain()
	
	local owner = self:GetDomainOwner()
	local ownerPos = owner:GetPos()
	for ent, _ in pairs(self.EntsInDomain) do
		if not ent:IsValid() then continue end
		if not ent:gebLib_IsPerson() then continue end
		if ent == owner then continue end
		
		local entPos = ent:GetPos()
		entPos.z = ownerPos.z
		ent:SetPos(entPos)
	end

	if CLIENT then
		local effectData = EffectData()
		effectData:SetEntity(self)
		effectData:SetRadius(1)
	
		util.Effect("spawn_effect", effectData)
	end
end

function ENT:DefaultOnRemove()
	hook.Remove("FinishMove", self.PredictedThinkName)
	hook.Run("gJujutsu_DomainEnd", self)

	local owner = self:GetDomainOwner()
	local weapon = owner:GetActiveWeapon()

	if CLIENT then
		local myPos = self:GetPos()

		if self.DomainType == DomainType.Barrier then
			CreateParticleSystemNoEntity("BlueOrb_Huge", myPos)
			CreateParticleSystemNoEntity("BlueOrb_Huge_Dust", myPos)
			CreateParticleSystemNoEntity("BlueOrb_Huge_Flare", myPos)
			CreateParticleSystemNoEntity("BlueOrb_Huge_FlareExplode", myPos)
			CreateParticleSystemNoEntity("BlueOrb_Huge_Shards", myPos)
			CreateParticleSystemNoEntity("BlueOrb_Huge_ShardsExplode", myPos)
		end
		
		CreateParticleSystemNoEntity("BlueOrb_ShardsExplode", myPos)
	end

	-- Stop all domain hurt sounds
	for i = 1, 3 do
		local soundToStop = Sound("gjujuts_kaisen/sfx/domain_expansion/crash_0" .. i .. ".wav")
		self:StopSound(soundToStop)
	end
	self:StopSound(Sound("gjujutsu_kaisen/sfx/general/other/Domain_Ambien.wav"))

	-- Now play the domain destroyed sound and remove the domain
	if SERVER then
		if owner:IsValid() then
			owner:GodDisable()
			owner:Freeze(false)
		end

		local domainFloor = self:GetDomainFloor()

		if domainFloor:IsValid() then
			domainFloor:Remove()
		end

		-- Remove children of the domain entity
		for child, _ in pairs(self.Children) do
			child:Remove()
		end

		self:EmitSound(self.DomainBreakSound)
	end

	if weapon:IsValid() and weapon:IsGjujutsuSwep() then
		weapon:SetGlobalCD(10)
		weapon:SetNextUltimate(CurTime() + weapon.UltimateCD)
	end
end

function ENT:DefaultOnTakeDamage(dmg)
	local curTime = CurTime()

	if curTime > self.NextDamageSound then
		self:EmitSound(Sound("gjujutsu_kaisen/sfx/domain_expansion/crash_0"..math.random(1,3)..".wav"))
	end

	self:SetHealth(self:Health() - dmg:GetDamage())

	if (self:Health() <= 0) then
		self:Remove()
	end

	self.NextDamageSound = curTime + self.DamageSoundTime
end

function ENT:OnTakeDamage(dmg)
	self:DefaultOnTakeDamage(dmg)
end

function ENT:OnRemove()
	self:DefaultOnRemove()
end

function ENT:CanTool()
	return false
end

function ENT:SetDomainType(domainType)
	self.DomainType = domainType
end

function ENT:IsInDomain(ent, useCache)
	if useCache == nil then useCache = true end

	if useCache and self.EntsInDomain[ent] then
		return true
	end

	local rangeSquared = self.Range * self.Range

	local distance = ent:GetPos():DistToSqr(self:GetPos())

	return distance <= rangeSquared
end
