AddCSLuaFile()

ENT.Type = "anim"

ENT.PrintName = "Hollow purple fragment"
ENT.Author = "El Tomlino"
ENT.Purpose = "For a cool bezier experience"
ENT.Category = "El Tomlino"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.StartPos = nil
ENT.BezierPos = nil
ENT.EndPos = nil

ENT.Start = 0

local lifeTime = math.Rand(0.2, 0.4)
local startWidth = math.Rand(10, 20)
local endWidth = 0
local textureRes = 1 / ( startWidth + endWidth ) * 0.5
local texture = "effects/beam_nocolor"
local color = Color(150, 0, 200)

function ENT:Initialize()
    -- self:SetModel("models/hunter/misc/sphere075x075.mdl")
    self.Start = CurTime()

    self:DrawShadow(false)
    
    if SERVER then
        util.SpriteTrail(self, 0, color, true, startWidth, endWidth, lifeTime, textureRes, texture)
    end

	if CLIENT then
        self.Particle = CreateParticleSystem(self, "purple_fragment", 1)
		self.Particle:SetShouldDraw(false)
    end
end

function ENT:Think()
    local owner = self:GetOwner()

    if SERVER and not owner:gebLib_ValidAndAlive() then
        self:Remove()
    end

    if SERVER then
		local fraction = CurTime() - self.Start

		local bezierPos = math.QuadraticBezier(math.min(fraction * 1.5, 1), self.StartPos, self.BezierPos, self.EndPos)
		self:SetPos(bezierPos)

        self:NextThink(CurTime())
        return true
    end
end

function ENT:Draw()
	if not self.Particle:IsValid() then return end

	self.Particle:Render()
end
