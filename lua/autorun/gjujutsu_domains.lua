if SERVER then
	util.AddNetworkString("gJujutsu_cl_runDomainExpansion")
	util.AddNetworkString("gJujutsu_cl_SyncClashKey")
end

gjujutsu_ClashWindUp = 2
gjujutsu_ClashTime = 10

gJujutsuDomains = {}

gJujutsuDomainClashCache = {} -- For avoiding expensive checks if player is in a clash
gJujutsuDomainClashes = {}

local keyRefreshInterval = 0.1 -- Runs the checking logic every this interval to avoid lag
local keyRefreshTime = 0
local keyRefreshCD = 2
local keyRange = {Min = 11, Max = 20}

local keyPressSound = Sound("misc/key_press.wav")
local keyChangeSounds = {
	Sound("misc/key_change_1.wav"),
	Sound("misc/key_change_2.wav"),
	Sound("misc/key_change_3.wav"),
}

-- Helper functions
local function GenerateNewKey()
	return math.random(keyRange.Min, keyRange.Max)
end

local function SyncKey(ply, key)
	if CLIENT then return end

	net.Start("gJujutsu_cl_SyncClashKey")
	net.WriteUInt(key, 6)
	net.Send(ply)
end

if SERVER then
	hook.Add("Tick", "gjujutsu_ClashRefreshKey", function()
		local curTime = CurTime()
	
		if curTime > keyRefreshTime then
			keyRefreshTime = curTime + keyRefreshInterval
	
			-- Refresh domain clash key for all players who are clashing
	
			for _, ply in player.Pairs() do
				if ply.gJujutsu_ClashKeyTime ~= nil and curTime < ply.gJujutsu_ClashKeyTime then continue end

				local weapon = ply:GetActiveWeapon()
	
				if not weapon:IsValid() then continue end
				if not weapon:IsGjujutsuSwep() then continue end
				if not weapon:GetDomainClash() then continue end
	
				local newKey = GenerateNewKey()

				ply.gJujutsu_ClashKey = newKey
				ply.gJujutsu_ClashKeyTime = curTime + keyRefreshCD

				SyncKey(ply, newKey)
			end
		end
	end)
end

hook.Add("Tick", "gJujutsu_DomainHandling", function()

	-- Remove domains from global table if they are not valid
	for owner, domain in pairs(gJujutsuDomains) do
		if not owner:IsValid() or not domain:IsValid() then
			gJujutsuDomains[owner] = nil
			continue
		end
	end

	if CLIENT then return end

	for owner, data in pairs(gJujutsuDomainClashes) do

		-- Domain clash start
		if CurTime() >= data.ClashStart and data.ClashStart ~= 0 then
			hook.Run("gJujutsu_DomainClashStart", owner, data)
			keyRefreshTime = 0
		end

		if CurTime() >= data.ClashEnd and data.ClashEnd ~= 0 then
			data.ClashEnd = 0
			local winner = data.Players[1]

			for _, ply in ipairs(data.Players) do
				if not ply:IsValid() then continue end
				
				-- Removing clash state
				local weapon = ply:GetActiveWeapon()
				
				if weapon:IsValid() and weapon:IsGjujutsuSwep() then
					weapon:SetDomainClash(false)
					weapon:SetBusy(false)
				end
				
				print(ply.gJujutsu_ClashPresses, winner.gJujutsu_ClashPresses)

				-- Determining winner
				if ply.gJujutsu_ClashPresses > winner.gJujutsu_ClashPresses then
					winner = ply
				end
			end

			-- Add stun to all the losing players
			for _, ply in ipairs(data.Players) do
				ply.gJujutsu_ClashPresses = 0
				ply:SetMoveType(ply.gJujutsu_OldMoveType)

				local weapon = ply:GetActiveWeapon()
				
				if weapon:IsValid() and weapon:IsGjujutsuSwep() then
					if ply == winner then
						weapon:SetGlobalCD(0.5)
					else
						weapon:SetGlobalCD(5)
					end
				end
			end
			print("Domain clash end")
			print("Winner: ", winner)

			if winner:IsValid() then
				local weapon = winner:GetActiveWeapon()

				if weapon:IsGjujutsuSwep() then
					weapon:DomainExpansion()

					-- Run domain expansion on all clients
					net.Start("gJujutsu_cl_runDomainExpansion")
					net.WriteEntity(weapon)
					net.Broadcast()
				end
			end

			gJujutsuDomainClashes[owner] = nil
			gJujutsuDomainClashCache[owner] = nil
		end
	end
end)

-- Sukuna's domain slash. I've put this here as its shared for both sukuna's domains, so it won't get copied
function SlashThink(self)
	if not self:GetDomainReady() then return end
	
	local owner = self:GetDomainOwner()
	
	if not owner:IsValid() then return end
	if not IsFirstTimePredicted() then return end
	local curTime = CurTime()

	if curTime < self.NextSlash then return end
	self.NextSlash = CurTime() + self.SlashCD

	local domainPos = self:GetPos()

	local dmgInfo = DamageInfo()
	if owner:IsValid() then dmgInfo:SetAttacker(owner) end
	if self:IsValid() then dmgInfo:SetInflictor(owner) end
	dmgInfo:SetInflictor(self)
	dmgInfo:SetDamage(math.random(self.SlashDamageMin, self.SlashDamageMax))
	
	-- Play effects for clients which are in the range
	if CLIENT then
		local ply = LocalPlayer()

		if ply:GetPos():Distance(domainPos) < self.Range then
			for i = 1, 2 do
				ply:EmitSound(Sound("gjujutsu_kaisen/sfx/domain_expansion/malevolent_shrine/swing_0"..math.random(1,5)..".wav", 75, math.random(70, 130), 0))
			end
			util.ScreenShake(ply:GetPos(), 1, 1, 0.1, 100, true)
		end
	end

	-- Decimate everything in range
	for _, ent in ents.Pairs() do
		if not ent:IsValid() then continue end
		if self.DomainBlacklist[ent:GetClass()] then continue end
		if self.Children[ent] then continue end
		if not ent:IsSolid() or ent == self or ent == owner then continue end

		local distance = ent:GetPos():Distance(domainPos)

		if distance > self.Range then continue end
		local randomVelocity = VectorRand() * 300

		if ent:IsNPC() then randomVelocity = randomVelocity / 10 end
		if ent:IsNextBot() then randomVelocity = vector_origin end
		if ent:IsPlayer() then randomVelocity = randomVelocity / 4 end
			
		dmgInfo:SetDamageForce(randomVelocity)

		if ent:IsPlayer() then
			ent:SetVelocity(randomVelocity + vector_up * 10)
		elseif not ent:IsNextBot() and not ent:IsNPC() then
			ent:SetVelocity(ent:GetVelocity() +  randomVelocity)
		end

		local phys = ent:GetPhysicsObject()

		if phys:IsValid() and not ent:IsNextBot() then
			SukunaPropCut(owner, ent, math.random(30,90))
			if not ent:IsNextBot() and not ent:IsPlayer() then
				phys:SetVelocity(phys:GetVelocity() +  randomVelocity)
			end
		end
		
		if SERVER then
			owner:LagCompensation(true)
			SuppressHostEvents(nil)
			ent:TakeDamageInfo(dmgInfo)
			SuppressHostEvents(owner)
			owner:LagCompensation(false)
			
			ent:EmitSound(Sound("gjujutsu_kaisen/sfx/domain_expansion/malevolent_shrine/hit_0"..math.random(1,2)..".wav"), 75, math.random(90, 110))
		end
	end
end

-- Handling hooks

-- When domain clash includes only 1 player, then there is no need to continue the clash
hook.Add("gJujutsu_DomainClashStart", "DomainClashOnlyOwner", function(owner, data)
	if not owner:IsValid() then return end

	if #data.Players == 1 then
		gJujutsuDomainClashCache[owner] = nil

		local weapon = owner:GetActiveWeapon()

		if weapon:IsValid() and weapon:IsGjujutsuSwep() then
			weapon:SetDomainClash(false)
			weapon:SetClashStart(false)
			weapon:SetBusy(false)
			weapon:DomainExpansion()
		end

		-- Run domain expansion on all clients
		net.Start("gJujutsu_cl_runDomainExpansion")
		net.WriteEntity(weapon)
		net.Broadcast()

		gJujutsuDomainClashes[owner] = nil
	end
end)

-- Normal clash handling
hook.Add("gJujutsu_DomainClashStart", "DomainClashStart", function(owner, data)
	if not owner:IsValid() then return end
	if #data.Players == 1 then return end

	for _, ply in pairs(data.Players) do
		local weapon = ply:GetActiveWeapon()

		if weapon:IsValid() and weapon:IsGjujutsuSwep() then
			weapon:SetDomainClash(true)
			weapon:SetBusy(true)
		end

		local newKey = GenerateNewKey()

		ply.gJujutsu_OldMoveType = ply:GetMoveType()
		ply.gJujutsu_ClashKey = newKey
		ply.gJujutsu_ClashKeyTime = 0
		
		ply:Freeze(false)
		ply:SetMoveType(MOVETYPE_NONE)

		SyncKey(ply, newKey)
	end
	
	data.ClashStart = 0
	data.ClashEnd = CurTime() + gjujutsu_ClashTime
end)

hook.Add("PlayerNoClip", "gJUjutsu_DomainClashNoClip", function(ply)
	local weapon = ply:GetActiveWeapon()

	if not weapon:IsValid() then return end
	if not weapon:IsGjujutsuSwep() then return end

	if weapon:GetDomainClash() then
		return false
	end
end)

if SERVER then return end

-- Handling nets

net.Receive("gJujutsu_cl_runDomainExpansion", function()
	local weapon = net.ReadEntity()
	
	if weapon:IsValid() then
		weapon:DomainExpansion()
	end
end)

net.Receive("gJujutsu_cl_SyncClashKey", function()
	local newKey = net.ReadUInt(6)
	local ply = LocalPlayer()

	if not ply:IsValid() then return end

	ply.gJujutsu_ClashKey = newKey
	ply:EmitSound(keyChangeSounds[math.random(1, #keyChangeSounds)])
	
	util.ScreenShake(ply:GetPos(), 25, 25, 2, 500, true)
	
	local weapon = ply:GetActiveWeapon()

	if weapon:IsGjujutsuSwep() then
		weapon:WindEffect(200, 0.55)
	end
end)

-- Debug commands

concommand.Add( "jjk_domainClashes", function( ply, cmd, args )
	if CLIENT then return end
	PrintTable(gJujutsuDomainClashes)
end )
