local statsUpdateRate = 0.3
local nextStatsUpdate = CurTime() + statsUpdateRate

function SWEP:SukunaConvarsThink()
	if SERVER and not self.MahoragaWheelConvar:GetBool() and self:GetMahoragaWheel():IsValid() then
		self:GetMahoragaWheel():Remove()
	end

	if SERVER and self:GetFingers() < self.MahoragaWheelFingerConVar:GetInt() and self:GetMahoragaWheel():IsValid() then
		self:GetMahoragaWheel():Remove()
	end
end
