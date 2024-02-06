AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Purple Red"
ENT.Author = "El Tomlino"
ENT.Purpose = "Dummy red for the hollow purple animation"
ENT.Category = "El Tomlino"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

ENT.Initialized = false
ENT.PostInitialized = false;

ENT.Particle = false

ENT.PurplePosOffset = 55

function ENT:Initialize()
	self.Initialized = true

	self:SetModel("models/xqm/rails/gumball_1.mdl")
    self:SetMaterial("entities/gojo_technique.vmt")
	self:SetColor(Color(218, 40, 40))
	self:SetMoveType(MOVETYPE_NONE)
    self:DrawShadow(false)
	
	if CLIENT and LocalPlayer() == self:GetOwner() then
		self:SetPredictable()
	end

	if CLIENT then
        self.Particle = CreateParticleSystem(self, "RedBall_Center", 1)
    end
end

function ENT:PostInitialize()
    self.PostInitialized = true
end

function ENT:Think()
    local owner = self:GetOwner()
    if SERVER and !IsValid(owner) or SERVER and !owner:Alive() then
        self:Remove()
    end
    if not self.Initialized then
        self:Initialize()
        return
    end
    if self.Initialized and not self.PostInitialized then
        self:PostInitialize()
    end
end

function ENT:Draw()
	if not self.Particle:IsValid() then return end
	self.Particle:SetShouldDraw(false)
	self.Particle:Render()
end
