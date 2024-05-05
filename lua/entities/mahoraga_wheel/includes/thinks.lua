


function ENT:AdaptThink()
	if CLIENT then return end
	
	if self:GetAdaptTimer() > 0 and CurTime() > self:GetAdaptTimer() then
		self:Adapt()
	end
end
