-- TODO: Optimize

function SWEP:StatsRegenThink()
	if self:GetBusy() then return end

	local owner = self:GetOwner()

	if not owner:IsValid() then return end
	if owner:IsFrozen() or not owner:Alive() then return end
	
	if not self:GetReverseTechniqueEnabled() and not self:GetInfinity() then
		self:SetCursedEnergy(math.min(self:GetCursedEnergy() + self:GetCursedEnergyRegen(), self:GetMaxCursedEnergy()))
		self:SetMind(math.min(self:GetMind() + self.MindRegen, self:GetMaxMind()))
	end
end

local mins = Vector(-10, -10, -10)
local maxs = Vector(10, 10, 10)

local onGroundColor = Color(0, 255, 0)
local normalColor = color_white
function SWEP:TeleportIndicatorThink()
	if SERVER then return end
	if not self:GetHoldingTeleport() then return end

	local owner = self:GetOwner()
	local indicator = owner.gJujutsu_TeleportIndicator

	if not indicator:IsValid() then return end

	local startPos = owner:EyePos()

	local traceData = {
		start = startPos,
		endpos = startPos + owner:GetAimVector() * 3000,
		filter = owner,
		mask = MASK_NPCWORLDSTATIC
	}

	local tr = util.TraceLine(traceData)
	
	local teleportPos = owner:gebLib_FindEmptyPosition(tr.HitPos, 500, 2, owner)

	traceData.start = teleportPos
	traceData.endpos = teleportPos - indicator:GetUp() * 2
	traceData.mins = mins
	traceData.maxs = maxs

	local traceDown = util.TraceHull(traceData)

	local angles = owner:GetAngles()
	angles.x = 0

	if traceDown.Hit then
		indicator:SetColor(onGroundColor)
	else 
		indicator:SetColor(normalColor)
	end

	indicator:SetSequence(owner:GetSequence())
	indicator:SetCycle(owner:GetCycle())
	indicator:SetPlaybackRate(owner:GetPlaybackRate())
	indicator:SetAngles(angles)
	indicator:SetPos(teleportPos)
end
