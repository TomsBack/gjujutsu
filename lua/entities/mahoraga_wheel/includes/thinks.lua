
function ENT:SpinThink()
	local lerpTime = (CurTime() - self:GetSpinTime()) / self.SpinSpeed
	local lerpedAngles = Lerp(math.ease.InOutBack(lerpTime), self:GetOriginalAngle(), self:GetDesiredAngle())
	lerpedAngles:Normalize()

	self:SetAngles(lerpedAngles)
end

function ENT:AdaptThink()
	if CLIENT then return end
	
	if self:GetAdaptTimer() > 0 and CurTime() > self:GetAdaptTimer() then
		self:Adapt()
	end
end
