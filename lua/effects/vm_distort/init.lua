local rotateAngle = Angle(2, 0, 0)

function EFFECT:Init(data)
	self.Position = data:GetOrigin()	
	self.Speed = data:GetMagnitude()
	self.Ent = data:GetEntity()

	self.Speed = self.Speed

	local emitter = ParticleEmitter(self.Position)
	local particle = emitter:Add("Effects/strider_pinch_dudv", self.Position)
	self.Particle = particle
	particle:SetAngleVelocity(rotateAngle)
	particle:SetDieTime(1.15)
	particle:SetStartAlpha(0)
	particle:SetEndAlpha(75)
	particle:SetStartSize(0)
	particle:SetEndSize(200)
	emitter:Finish()
end

function EFFECT:Render()
end

function EFFECT:Think()
	return true
end
