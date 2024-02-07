AddCSLuaFile()

ENT.PrintName = "Domain Expansion: Infinity Voide"
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

ENT.DamageMaterial1 = "models/limitless/domain_crack1.vmt"
ENT.DamageMaterial2 = "models/limitless/domain_crack2.vmt"

ENT.SlashCD = 0.07
ENT.SlashDamageMin = 10
ENT.SlashDamageMax = 30
ENT.NextSlash = 0

ENT.Shrine = NULL

function ENT:SetupDataTables()
	self:DefaultDataTables()
end

function ENT:Initialize()
	self.Initialized = true
	self:DefaultInitialize()

	local owner = self:GetDomainOwner()
	local aimAngles = owner:GetAimVector():Angle()

	if SERVER then
		local shrine = ents.Create("malevolent_shrine")
		self.Shrine = shrine
		self.Children[shrine] = true
		shrine:SetOwner(self)
		shrine:SetMoveType(MOVETYPE_NONE)
		shrine:SetSkin(1)
		shrine:SetPos(owner:GetPos() + aimAngles:Forward() * -265)
		shrine:SetAngles(aimAngles)
		shrine:Spawn()

		shrine:SetSequence(1)
		shrine:SetPlaybackRate(0)

		local phys = shrine:GetPhysicsObject()

		if phys:IsValid() then
			phys:EnableMotion(false)
			phys:EnableGravity(false)
		end
	end

	self:SetTimedEvent("RevealShrine", 9.5)
end

function ENT:Think()
	if not self.Initialized then
        self:Initialize()
        return
    end
end

function ENT:DefaultPredictedThink(ply, mv)
	SlashThink(self)
	self:CheckEntsInDomain()
	self:DefaultThink()
	self:LifeTimeThink()
	self:OwnerDiedThink()
	self:ResetDefaultsThink()
	self:DamageMaterialThink()
	self:EventThink()
end 

function ENT:RevealShrine()
	if SERVER then
		self.Shrine:SetSkin(0)
		self.Shrine:SetPlaybackRate(1)
	end

	self:SetTimedEvent("StartDomain", 1)
end

function ENT:StartDomain()
	self:SetSpawnTime(CurTime())
	self:SetDomainReady(true)
	self:SpawnParticles()

	print("Domain ready")
end

function ENT:SpawnParticles()
	if SERVER then return end
	if not IsFirstTimePredicted() then return end
	if not self:IsValid() then return end
	
	CreateParticleSystem(self, "Shrine_Medium", PATTACH_ABSORIGIN_FOLLOW, 1)
	CreateParticleSystem(self, "Shrine_Medium", PATTACH_ABSORIGIN_FOLLOW, 1)
end

local domainMat1 = Material("models/limitless/mats_domain_sukuna2")
local domainMat2 = Material("models/limitless/mats_domain_sukuna3")
local skyColor =  Color(85, 0, 0, 255)
local floorColor = Color(110, 110, 110, 200)

function ENT:Draw()
	local ply = LocalPlayer()
	local domainPos = self:GetPos()

	if self:IsInDomain(ply) then
		cam.Start3D()
			cam.IgnoreZ(true)
				render.SuppressEngineLighting(true)
					render.SetMaterial(domainMat1)
					render.DrawSphere(domainPos, -9999, 9999, 9999, skyColor)
					render.SetMaterial(domainMat2)
					render.DrawQuadEasy(domainPos + vector_up, vector_up, 99999, 99999, floorColor, 0)
				render.SuppressEngineLighting(false)
			cam.IgnoreZ(false)

			if IsValid(ply.copyjjk) then
				ply.copyjjk:DrawModel()
			end

			for child, _ in pairs(self.Children) do
				child:DrawModel()
			end

			for ent, _ in pairs(self.EntsInDomain) do
				if ent == ply and ply.copyjjk:IsValid() then continue end
				ent:DrawModel()
			end
		cam.End3D()
	else
		render.OverrideDepthEnable(true, true)
			render.SetBlend(math.Remap(self:Health(), 0, self.DefaultHealth, 0, 1))
			self:DrawModel()
		render.OverrideDepthEnable(false) 
	end
end
