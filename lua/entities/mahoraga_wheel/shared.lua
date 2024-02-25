AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Mahoraga's Wheel"
ENT.Author = "El Tomlino"
ENT.Purpose = "To adapt to all phenomena"
ENT.Category = "El Tomlino"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.AutomaticFrameAdvance = true

ENT.Initialized = false
ENT.PostInitialized = false

ENT.Model = Model("models/chromeda/wheel.mdl")
ENT.PredictedThinkName = ""

ENT.SpinSpeed = 0.25

ENT.AdapationEnts = {}

ENT.SpinSound = Sound("sukuna/sfx/mahoraga_wheel_turn.wav")

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "ShouldSpin")
	
	self:NetworkVar("Float", 0, "SpinTime")

	self:NetworkVar("Angle", 0, "OriginalAngle")
	self:NetworkVar("Angle", 1, "DesiredAngle")
end

function ENT:Initialize()
	self.Initialized = true

	self:SetModel(self.Model)
	self:SetAngles(angle_zero)

	if CLIENT then
		self:SetPredictable(true)
	end

	timer.Simple(3, function()
		self:Spin()
	end)
end

function ENT:Think()
	local lerpTime = (CurTime() - self:GetSpinTime()) / self.SpinSpeed
	local lerpedAngles = Lerp(math.ease.InOutBack(lerpTime), self:GetOriginalAngle(), self:GetDesiredAngle())
	lerpedAngles:Normalize()

	self:SetAngles(lerpedAngles)

	if SERVER then
		self:NextThink(CurTime())
		return true
	end
end

function ENT:Spin()
	local angles = self:GetAngles()
	local rotatedAngles = self:GetAngles()
	rotatedAngles.y = rotatedAngles.y - 45

	if SERVER then
		self:EmitSound(self.SpinSound, 75, math.random(95, 105), 1, CHAN_STATIC)
	end

	self:SetOriginalAngle(angles)
	self:SetDesiredAngle(rotatedAngles)
	self:SetSpinTime(CurTime())
	self:SetShouldSpin(true)

	timer.Simple(3, function()
		self:Spin()
	end)
end
