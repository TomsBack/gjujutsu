AddCSLuaFile()

ENT.PrintName = "Domain Expansion: Infinite Void"
ENT.Author = "El Tomlino" 
ENT.Contact = "Steam"
ENT.Purpose = "Infinity Voide!"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.Category = "Domain Expansions"
ENT.Base = "domain_base"

ENT.AutomaticFrameAdvance = true
ENT.RenderGroup	= RENDERGROUP_BOTH

ENT.DomainType = DomainType.Barrier

ENT.SlashCD = 0.07
ENT.SlashDamageMin = 10
ENT.SlashDamageMax = 30
ENT.NextSlash = 0

ENT.VoidCore = NULL
ENT.DomainSplatters = NULL
ENT.AfterCinematic = false

ENT.EnergyDrain = 0.5

local cinematicSound = Sound("gjujutsu_kaisen/sfx/domain_expansion/infinity_voide/gojo_domain_v2.wav")
local domainAmbienceSound = Sound("gjujutsu_kaisen/sfx/gojo/domain_ambience.wav")

function ENT:SetupDataTables()
	self:DefaultDataTables()
end

function ENT:Initialize()
	self.Initialized = true
	self:DefaultInitialize()
end

function ENT:Think()
	if not self.Initialized then
        self:Initialize()
        return
    end

	if SERVER then
		self:NextThink(CurTime())
		return true
	end
end

function ENT:DefaultPredictedThink(ply, mv)
	self:CheckEntsInDomain()
	self:DefaultThink()
	self:LifeTimeThink()
	self:OwnerDiedThink()
	self:ResetDefaultsThink()
	self:DamageMaterialThink()
	self:EventThink()
	self:DrainEnergyThink()
end 

function ENT:StartDomain()
	self:DefaultStartDomain()
	self:SpawnParticles()
end

function ENT:SpawnParticles()
	if SERVER then return end
	-- if not IsFirstTimePredicted() then return end
	if not self:IsValid() then return end

	local owner = self:GetDomainOwner()

	local voidCoreParticle = CreateParticleSystemNoEntity("void_core", owner:EyePos() + owner:GetForward() * 2500)
	voidCoreParticle:SetShouldDraw(false)

	self.VoidCore = voidCoreParticle
end

local domainMat = Material("models/limitless/mats_domain")

function ENT:Draw()
	local ply = LocalPlayer()
	local domainPos = self:GetPos()

	local owner = self:GetDomainOwner()
	local weapon = owner:GetActiveWeapon()

	if not weapon:IsValid() then return end

	if weapon:GetInCinematic() and self:IsInDomain(ply) then
		return false
	end

	if not weapon:GetInCinematic() and self:IsInDomain(ply) and not self.AfterCinematic then
		self.AfterCinematic = true

		local domainSplattersParticle = CreateParticleSystemNoEntity("domain_splatters", self:GetPos())
		domainSplattersParticle:SetShouldDraw(false)
		self.DomainSplatters = domainSplattersParticle

		self:EmitSound(domainAmbienceSound, 0)
	end

	if self:GetDomainFloor():IsValid() then
		self:GetDomainFloor():DrawModel()
	end

	if self:IsInDomain(ply) then
		render.SetMaterial(domainMat)
		render.DrawScreenQuad()

		for child, _ in pairs(self.Children) do
			child:DrawModel()
		end
		cam.IgnoreZ(true)
		
		if self.DomainSplatters:IsValid() then
			self.DomainSplatters:Render()
		end

		if self.VoidCore:IsValid() then
			self.VoidCore:Render()
		end
		cam.IgnoreZ(false)

		for ent, _ in pairs(self.EntsInDomain) do
			if not ent:IsValid() then continue end
			if ent == owner and ent.gJujutsu_Copy:IsValid() then continue end
			
			ent:DrawModel()
		end
	else
		render.SetBlend(math.Remap(self:Health(), 0, self.DefaultHealth, 0, 1))
		self:DrawModel()
		render.SetBlend(1)
	end
end

function ENT:OnRemove()
	self:DefaultOnRemove()

	if CLIENT then
		if self.VoidCore:IsValid() then
			self.VoidCore:StopEmission()
		end

		if self.DomainSplatters:IsValid() then
			self.DomainSplatters:StopEmission()
		end
	end

	self:StopSound(domainAmbienceSound)

	for ent, _ in pairs(self.EntsInDomain) do
		self:UnfreezeEntity(ent)

		ent:StopSound(cinematicSound)
	end
end

function ENT:FreezeEntity(ent)
	if not ent:IsValid() then return end
	if ent:GetClass() == "hollow_purple" then return end

	local owner = self:GetDomainOwner()
	if ent == owner then return end

	if ent:IsPlayer() then
		local weapon = ent:GetActiveWeapon()

		if weapon:IsGjujutsuSwep() then
			weapon:DisableReverseCursed()
		end

		if weapon:Gjujutsu_IsGojo() and weapon:GetInfinity() then
			weapon:SetInfinity(false)
		end
	end

	if not ent:IsPlayer() then
		ent.gJujutsu_OldMoveType = ent:GetMoveType()
		
		ent:SetMoveType(MOVETYPE_NONE)
		ent:AddEFlags(EFL_NO_THINK_FUNCTION)
	end

	if SERVER and ent:IsPlayer() then
		ent:Freeze(true)
	end
end

function ENT:UnfreezeEntity(ent)
	if not ent:IsValid() then return end
	if ent:GetClass() == "hollow_purple" then return end

	local owner = self:GetDomainOwner()
	if ent == owner then return end

	if not ent:IsPlayer() then
		ent:SetMoveType(ent.gJujutsu_OldMoveType)
		ent:RemoveEFlags(EFL_NO_THINK_FUNCTION)
	end

	if SERVER and ent:IsPlayer() then
		ent:Freeze(false)
	end
end

hook.Add("gJujutsu_EntEnteredDomain", "gojo_enterDomain", function(domain, ent)
	if not domain:IsValid() then return end
	if domain:GetClass() ~= "gojo_domain" then return end

	domain:FreezeEntity(ent)
	
	if CLIENT and ent == LocalPlayer() then
		local owner = domain:GetDomainOwner()
		local weapon = owner:GetActiveWeapon()

		if weapon:IsGjujutsuSwep() then
			weapon:SetBlock(false)
		end

		if weapon:Gjujutsu_IsGojo() and not weapon:GetInCinematic() and IsFirstTimePredicted() then
			domain:EmitSound(domainAmbienceSound, 0)
		end
	end
end)

hook.Add("gJujutsu_EntLeftDomain", "gojo_leftDomain", function(domain, ent)
	if not domain:IsValid() then return end
	if domain:GetClass() ~= "gojo_domain" then return end

	domain:UnfreezeEntity(ent)

	if CLIENT and ent == LocalPlayer() and IsFirstTimePredicted() then
		domain:StopSound(domainAmbienceSound)
	end
end)
