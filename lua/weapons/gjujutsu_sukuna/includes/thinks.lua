local statsUpdateRate = 0.3
local nextStatsUpdate = CurTime() + statsUpdateRate

function SWEP:SukunaConvarsThink()
	if SERVER and not self.MahoragaWheelConvar:GetBool() and self:GetMahoragaWheel():IsValid() then
		self:GetMahoragaWheel():Remove()
	end

	if SERVER and self:GetFingers() < self.MahoragaWheelFingerConVar:GetInt() and self:GetMahoragaWheel():IsValid() then
		self:GetMahoragaWheel():Remove()
	end
	local owner = self:GetOwner()
	self.RepeatAnim = self.RepeatAnim or CurTime()
	if self:GetDrawingFireArrow() then
		if CurTime() > self.RepeatAnim then
			self.RepeatAnim = CurTime() + 8.5
			owner:gebLib_PlayAction("FugaCharge", 1)
		end
	end
	self.FixOtDalbaebov = self.FixOtDalbaebov or CurTime()
	if CurTime() > self.FixOtDalbaebov then
		self.FixOtDalbaebov = CurTime() + 0.1
		self:SetupModel()
	end
	self.DimensionalSlashDelay = self.DimensionalSlashDelay or CurTime()
	if CurTime() > self:GetDimensionalSlashDelay() then
		if self:GetDimensionalSlashState() != 0 then
			self:SetDimensionalSlashState(0)
		end
	end
end
