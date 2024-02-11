AddCSLuaFile()

ENT.PrintName = "Domain Expansion: Malevolent Shrine"
ENT.Author = "Tom" 
ENT.Contact = "Steam"
ENT.Purpose = "Malevolent Shrine!"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.Category = "Domain Expansions"
ENT.Base = "domain_base"

ENT.AutomaticFrameAdvance = true
ENT.RenderGroup	= RENDERGROUP_OPAQUE

ENT.DomainModel = Model("models/gjujutsu/malevolent_shrine/malevolent_shrine.mdl")
ENT.DomainType = DomainType.Barrierless

ENT.DamageMaterial1 = "models/limitless/domain_crack1.vmt"
ENT.DamageMaterial2 = "models/limitless/domain_crack2.vmt"

ENT.Range = 7000

ENT.SlashCD = 0.02
ENT.SlashDamageMin = 20
ENT.SlashDamageMax = 55
ENT.NextSlash = 0

ENT.EnergyDrain = 2 -- How much cursed energy it drains per tick

ENT.Particles = {}

function ENT:SetupDataTables()
	self:DefaultDataTables()
end

function ENT:Initialize()
	self.Initialized = true
	self:DefaultInitialize()

	self:SetSequence(1)
	self:SetPlaybackRate(0)
	self:SetNoDraw(true)

	if CLIENT then	
		self:SetRenderBoundsWS(Vector(-9999999, -9999999, -9999999), Vector(9999999, 9999999, 9999999))
		self:SetRenderBounds(Vector(-9999999, -9999999, -9999999), Vector(9999999, 9999999, 9999999))
		self:SetRenderClipPlaneEnabled(false)
	end

	self:SetTimedEvent("RevealShrine", 6.58)
end

function ENT:PostInitialize()
	self.PostInitialized = true

	if not self:IsValid() then return end

	-- self:SetSkin(1) -- This hides the malevolent shrine
end

function ENT:Think()
	if not self.Initialized then
        self:Initialize()
        return
    end

    if self.Initialized and not self.PostInitialized then
        self:PostInitialize()
    end

	if SERVER then
		self:NextThink(CurTime())
		return true
	end
end

function ENT:Draw()
	if not self:IsValid() then return end

	for _, particle in ipairs(self.Particles) do
		if not particle:IsValid() then continue end

		particle:SetShouldDraw(false)
		particle:Render()
	end

	render.OverrideDepthEnable(true, true)
	render.SetBlend(math.Remap(self:Health(), 0, self.DefaultHealth, 0, 1))
	self:DrawModel()
	render.OverrideDepthEnable(false)
end

function ENT:DefaultPredictedThink(ply, mv)
	SlashThink(self)
	self:CheckEntsInDomain()
	self:LifeTimeThink()
	self:OwnerDiedThink()
	self:ResetDefaultsThink()
	self:DamageMaterialThink()
	self:EventThink()
	self:DrainEnergyThink()
end

function ENT:RevealShrine()
	self:SetNoDraw(false)
	local effectData = EffectData()
	effectData:SetEntity(self)

	util.Effect("spawn_effect", effectData)

	self:SetTimedEvent("StartShrine", 4.3)
end

function ENT:StartShrine()
	self:SetSkin(0)
	self:SetPlaybackRate(1)

	self:SetTimedEvent("StartDomain", 1)
end

function ENT:StartDomain()
	local owner = self:GetDomainOwner()

	if not owner:PredictedOrDifferentPlayer() then return end

	self:SetSpawnTime(CurTime())
	self:SetDomainReady(true)
	self:SpawnParticles()

	if CLIENT and IsFirstTimePredicted() then
		print("AA")
		owner:EmitSound("gjujutsu_kaisen/sukuna/shrine_burst.wav")
	end
end

function ENT:OnRemove()
	self:DefaultOnRemove()
	local owner = self:GetDomainOwner()

	if owner:IsValid() then
		owner:StopSound(Sound("sukuna/sfx/domain_theme.mp3"))
	end
end

function ENT:SpawnParticles()
	if SERVER then return end
	if not IsFirstTimePredicted() then return end
	if not self:IsValid() then return end

	print("spawning particles")
	table.insert(self.Particles, CreateParticleSystem(self, "Shrine_Large", PATTACH_ABSORIGIN_FOLLOW, 1))
	table.insert(self.Particles, CreateParticleSystem(self, "Shrine_Large", PATTACH_ABSORIGIN_FOLLOW, 1))
end
