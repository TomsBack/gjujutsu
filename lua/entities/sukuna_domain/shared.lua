AddCSLuaFile()

if SERVER then
	util.AddNetworkString("gjujutsu_cl_domainParticles")
end

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

ENT.Range = 2500

ENT.SlashCD = 0.02
ENT.SlashDamage = 15
ENT.NextSlash = 0

ENT.EnergyDrain = 2 -- How much cursed energy it drains per tick

ENT.Particles = {}
ENT.SpawnedParticles = false

local renderMins = Vector(-9999999, -9999999, -9999999)
local renderMaxs = Vector(9999999, 9999999, 9999999)

ENT.DomainBurstSound = Sound("sukuna/sfx/shrine_burst.wav")
ENT.DomainThemeSound = Sound("sukuna/sfx/domain_theme.mp3")

function ENT:SetupDataTables()
	self:DefaultDataTables()
end

function ENT:Initialize()
	self.Initialized = true

	local owner = self:GetDomainOwner()

	if owner:IsValid() then
		local weapon = owner:GetActiveWeapon()

		if weapon:IsValid() and weapon:Gjujutsu_IsSukuna() then
			local fingers = weapon:GetFingers()

			self.Range = self.Range * (1 + fingers / 5)
			self.SlashDamage = self.SlashDamage * (1 + fingers / 5)

			gebLib.PrintDebug("Range", self.Range)
			gebLib.PrintDebug("Slash damage", self.SlashDamage)
		end 
	end

	self:DefaultInitialize()

	self:SetSequence(1)
	self:SetPlaybackRate(0)
	self:DrawShadow(true)
	
	if CLIENT then	
		self:SetNoDraw(true)
		self:SetRenderBoundsWS(renderMins, renderMaxs)
		self:SetRenderBounds(renderMins, renderMaxs)
		self:SetRenderClipPlaneEnabled(false)
	end

	self:SetTimedEvent("RevealShrine", 6.68)
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

	if game.SinglePlayer() then
		SlashThink(self)
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
	render.SetBlend(1)
end

function ENT:DefaultPredictedThink(ply, mv)
	if not game.SinglePlayer() then
		SlashThink(self)
	end
	self:CheckEntsInDomain()
	self:LifeTimeThink()
	self:OwnerDiedThink()
	self:ResetDefaultsThink()
	self:DamageMaterialThink()
	self:EventThink()
	self:DrainEnergyThink()
end

function ENT:RevealShrine()
	if CLIENT then
		local effectData = EffectData()
		-- effectData:SetRadius(0.25)
		effectData:SetEntity(self)
		
		util.Effect("spawn_effect", effectData)
		self:SetNoDraw(false)
	end

	self:SetTimedEvent("StartShrine", 4.2)
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

	if SERVER and game.SinglePlayer() then
		net.Start("gjujutsu_cl_domainParticles")
		net.WriteEntity(self)
		net.Broadcast()
	end

	if CLIENT then
		self:SpawnParticles()
		
		if IsFirstTimePredicted() or game.SinglePlayer() then
			owner:EmitSound(self.DomainBurstSound)
		end
	end
end

function ENT:OnRemove()
	self:DefaultOnRemove()
	local owner = self:GetDomainOwner()

	if owner:IsValid() then
		owner:StopSound(self.DomainThemeSound)
	end

	if CLIENT then
		for _, particle in ipairs(self.Particles) do
			if not particle:IsValid() then continue end
			particle:SetShouldDraw(true)
			particle:StopEmission()
		end
	end
end

function ENT:SpawnParticles()
	if SERVER then return end
	if not self:IsValid() then return end

	local owner = self:GetDomainOwner()

	if not owner:gebLib_PredictedOrDifferentPlayer() and not game.SinglePlayer() then return end
	if self.SpawnedParticles then return end
	self.SpawnedParticles = true

	if not owner:IsValid() then return end
	local ownerPos = owner:EyePos()

	print("spawning particles for domain")

	table.insert(self.Particles, CreateParticleSystemNoEntity("Shrine_Large", ownerPos))
	table.insert(self.Particles, CreateParticleSystemNoEntity("Shrine_Large", ownerPos))
end

-- Sukuna's domain slash. I've put this here as its shared for both sukuna's domains, so it won't get copied
function SlashThink(self)
	if not self:GetDomainReady() then return end
	
	local owner = self:GetDomainOwner()
	
	if not owner:IsValid() then return end
	if not IsFirstTimePredicted() then return end
	local curTime = CurTime()

	if curTime < self.NextSlash then return end
	self.NextSlash = CurTime() + self.SlashCD

	local domainPos = self:GetPos()

	local dmgInfo = DamageInfo()
	if owner:IsValid() then dmgInfo:SetAttacker(owner) end
	if self:IsValid() then dmgInfo:SetInflictor(self) end
	dmgInfo:SetDamageType(5)
	dmgInfo:SetDamage(self.SlashDamage)
	
	-- Play effects for clients which are in the range
	if CLIENT then
		local ply = LocalPlayer()

		if self:IsInDomain(ply) then
			ply:EmitSound(Sound("gjujutsu_kaisen/sfx/domain_expansion/malevolent_shrine/swing_0"..math.random(1,5)..".wav", 75, math.random(70, 130), 0))
			util.ScreenShake(ply:GetPos(), 1, 1, 0.1, 100, true)
		end
	end

	-- Decimate everything in range
	for ent, _ in pairs(self.EntsInDomain) do
		if not ent:IsValid() then continue end
		if self.Children[ent] then continue end
		if ent == owner then continue end

		local randomVelocity = VectorRand() * 300

		if ent:IsNPC() then randomVelocity = randomVelocity / 10 end
		if ent:IsNextBot() then randomVelocity = vector_origin end
		if ent:IsPlayer() then randomVelocity = randomVelocity / 4 end

		local customDamageType = gebLib_DamageExceptions[ent:GetClass()]

		if customDamageType ~= nil then
			dmgInfo:SetDamageType(customDamageType)
		else
			dmgInfo:SetDamageType(5)
		end

		dmgInfo:SetDamageForce(randomVelocity)

		if ent:IsPlayer() then
			ent:SetVelocity(randomVelocity + vector_up * 10)
		elseif not ent:IsNextBot() and not ent:IsNPC() then
			ent:SetVelocity(ent:GetVelocity() +  randomVelocity)
		end

		local phys = ent:GetPhysicsObject()

		if not ent:gebLib_IsPerson() and phys:IsValid() then
			SukunaPropCut(owner, ent, math.random(30,90))

			phys:SetVelocity(phys:GetVelocity() + randomVelocity)
		end
		
		if SERVER then
			owner:LagCompensation(true)
			SuppressHostEvents(nil)
			ent:TakeDamageInfo(dmgInfo)
			SuppressHostEvents(owner)
			owner:LagCompensation(false)
			
			ent:EmitSound(Sound("gjujutsu_kaisen/sfx/domain_expansion/malevolent_shrine/hit_0"..math.random(1,2)..".wav"), 75, math.random(90, 110))
		end
	end
end

-- Handling hooks

hook.Add("gJujutsu_EntEnteredDomain", "sukuna_enterDomain", function(domain, ent)
	if not domain:IsValid() then return end
	if domain:GetClass() ~= "sukuna_domain" then return end

	if ent:IsPlayer() then
		local weapon = ent:GetWeapon("gjujutsu_gojo")

		gebLib.PrintDebug("Turning infinity off because of domain for", ent)

		if weapon:IsValid() then
			weapon:SetInfinity(false)
		end
	end
end)


-- Handling nets

if CLIENT then
	net.Receive("gjujutsu_cl_domainParticles", function()
		local domain = net.ReadEntity()

		if not domain:IsValid() then return end
		local owner = domain:GetDomainOwner()

		domain:SpawnParticles()

		if owner:IsValid() then
			owner:EmitSound(domain.DomainBurstSound)
		end
	end)
end
