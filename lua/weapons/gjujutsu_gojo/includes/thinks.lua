-- TODO: Optimize infinity

local sixEyesMultConvar = GetConVar("gjujutsu_gojo_six_eyes_damage_mult")

local convarCD = 0.5
local nextConvarUpdate = 0

function SWEP:InfinityThink()
	if not self:GetInfinity() then return end
	local owner = self:GetOwner()

	-- Disable infinity when you have 0 cursed energy
	if self:GetCursedEnergy() <= 0 then
		self:SetInfinity(false)
	
		self:DisableInfinityProps()
		return
	end

	if not owner:IsValid() then return end

	local ownerPos = owner:GetPos()
	local ownerCenter = owner:WorldSpaceCenter()
	local ownerVelocity = owner:GetVelocity()

	local dmgInfo = DamageInfo()
	if owner:IsValid() then
		dmgInfo:SetAttacker(owner)
		dmgInfo:SetInflictor(owner)
	end
	dmgInfo:SetDamageType(DMG_GENERIC)

	for _, ent in ents.Pairs() do
		if not ent:IsValid() then continue end
		if self.InfinityBlacklist[ent:GetClass()] then return end
		if ent:IsPlayer() or ent:IsNextBot() then continue end

		local entPos = ent:GetPos()
		local distance = ownerPos:Distance(ent:GetPos())
		local phys = ent:GetPhysicsObject()

		local repelDirection = (entPos - ownerCenter):GetNormalized()
		repelDirection.z = 0

		if distance <= self.InfinityRadius and not ent.gJujutsu_InfinityEffect then
			ent.gJujutsu_InfinityEffect = true
			ent.gJujutsu_OldMoveType = ent:GetMoveType()
			
			ent:SetMoveType(MOVETYPE_NONE)
			ent:SetVelocity(vector_origin)
			if not ent:IsNPC() then
				ent:AddEFlags(EFL_NO_THINK_FUNCTION)
			end
			
			if phys:IsValid() then
				ent.gJujutsu_OldGravity = phys:IsGravityEnabled()
				phys:SetVelocityInstantaneous(vector_origin)
				phys:SetAngleVelocityInstantaneous(vector_origin)
				phys:EnableGravity(false)
			end

			continue
		end

		if distance > self.InfinityRadius and ent.gJujutsu_InfinityEffect then
			ent.gJujutsu_InfinityEffect = false

			ent:SetMoveType(ent.gJujutsu_OldMoveType)
			if not ent:IsNPC() then
				ent:RemoveEFlags(EFL_NO_THINK_FUNCTION)
			end

			if phys:IsValid() then
				phys:EnableGravity(ent.gJujutsu_OldGravity)
				phys:Wake()
			end
		end
	end

	if true then return end
	
	for _, ent in ents.Pairs() do
		if not ent:IsValid() then continue end
		local entPos = ent:GetPos()
		local distance = ownerPos:Distance(ent:GetPos())

		local repelDirection = (entPos - ownerCenter):GetNormalized()
		repelDirection.z = 0

		-- Dealing damage
		local traceData = {
			start = entPos,
			endpos = entPos + repelDirection * 10,
			filter = ent,
		}
		
		owner:LagCompensation(true)
		local repelTrace = util.TraceLine(traceData)

		if repelTrace.Hit then
			dmgInfo:SetDamage(math.Rand(0.75, 2))
			if SERVER then
				SuppressHostEvents(nil)
				ent:TakeDamageInfo(dmgInfo)
				SuppressHostEvents(owner)
			end

			continue
		end
		owner:LagCompensation(false)
	end

	if ownerVelocity:IsZero() then return end

	for _, ent in pairs(ents.FindInCone(ownerCenter, ownerVelocity, 100, 0.2)) do
		if not ent.gJujutsu_InfinityEffect then continue end
		local entPos = ent:GetPos()

		local repelDirection = (entPos - ownerCenter):GetNormalized()
		repelDirection.z = 0

		local traceData = {
			start = entPos,
			endpos = entPos + repelDirection * 10,
			filter = ent,
		}
		
		owner:LagCompensation(true)
		local repelTrace = util.TraceLine(traceData)
		owner:LagCompensation(false)

		if repelTrace.Hit then continue end

		local repelPos = entPos + repelDirection * 5
		ent:SetPos(repelPos)

		local phys = ent:GetPhysicsObject()

		if phys:IsValid() then
			phys:SetPos(repelPos)
		end
	end
end

function SWEP:StatsRegenThink()
	if self:GetBusy() then return end

	local owner = self:GetOwner()

	if not owner:IsValid() then return end
	if owner:IsFrozen() or not owner:Alive() then return end
	
	if not self:GetReverseTechniqueEnabled() and not self:GetInfinity() then
		self:SetCursedEnergy(math.min(self:GetCursedEnergy() + self:GetCursedEnergyRegen(), self:GetMaxCursedEnergy()))
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
	local indicator = self.TeleportIndicator

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

function SWEP:FlightThink()
	if not self:GetFlying() then return end

	if self:GetFlying() and not self:GetInfinity() then
		self:DisableFlight()
	end
	
	if self:GetCursedEnergy() <= 0 then
		self:DisableFlight()
	end

	self:RemoveCursedEnergy(self.FlightDrain)
end

function SWEP:GojoConvarsThink()
	if CurTime() < nextConvarUpdate then return end
	nextConvarUpdate = CurTime() + convarCD

	self.SixEyesDamageMultiplier = sixEyesMultConvar:GetFloat()
	if self:GetSixEyes() then
		self.DamageMultiplier = self.SixEyesDamageMultiplier
	end
	
	if self:GetInfinity() and not self.InfinityConvar:GetBool() then
		self:SetInfinity(false)
	end
end
