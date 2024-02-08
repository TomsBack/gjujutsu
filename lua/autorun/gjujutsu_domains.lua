if SERVER then
	util.AddNetworkString("gJujutsu_cl_runDomainExpansion")
end

gjujutsu_ClashWindUp = 1
gjujutsu_ClashTime = 5

gJujutsuDomains = {}

gJujutsuDomainClashCache = {} -- For avoiding expensive checks if player is in a clash
gJujutsuDomainClashes = {}

hook.Add("Tick", "gJujutsu_DomainHandling", function()
	for owner, domain in pairs(gJujutsuDomains) do
		if not owner:IsValid() or not domain:IsValid() then
			gJujutsuDomains[owner] = nil
			continue
		end
	end

	if CLIENT then return end

	for owner, data in pairs(gJujutsuDomainClashes) do
		if CurTime() >= data.ClashStart and data.ClashStart ~= 0 then

			print("Domain clash start", #data.Players)
			if #data.Players == 0 then
				gJujutsuDomainClashCache[owner] = nil

				local weapon = owner:GetActiveWeapon()

				if weapon:IsValid() and weapon:IsGjujutsuSwep() then
					weapon:SetDomainClash(false)
					weapon:DomainExpansion()
				end

				print("only one player")
				-- Run domain expansion on all clients
				net.Start("gJujutsu_cl_runDomainExpansion")
				net.WriteEntity(weapon)
				net.Broadcast()

				print("clear owner short")
				gJujutsuDomainClashes[owner] = nil
				continue
			end
			
			data.ClashStart = 0
			data.ClashEnd = CurTime() + gjujutsu_ClashTime
		end

		if CurTime() >= data.ClashEnd and data.ClashEnd ~= 0 then
			data.ClashEnd = 0
			local winner = data.Players[0]

			for _, plyData in ipairs(data.Players) do
				if not plyData.Player:IsValid() then continue end

				-- Removing clash state
				local weapon = plyData.Player:GetActiveWeapon()

				if weapon:IsValid() and weapon:IsGjujutsuSwep() then
					weapon:SetDomainClash(false)
				end

				-- Determining winner
				if plyData.Presses > winner.Presses then
					winner = plyData
				end
			end

			local winnerPlayer = winner.Player

			if winnerPlayer:IsValid() then
				local weapon = winnerPlayer:GetActiveWeapon()

				if weapon:IsGjujutsuSwep() then
					weapon:DomainExpansion()

					-- Run domain expansion on all clients
					net.Start("gJujutsu_cl_runDomainExpansion")
					net.WriteEntity(weapon)
					net.Broadcast()
				end
			end

			print("owner delete")
			gJujutsuDomainClashes[owner] = nil
			gJujutsuDomainClashCache[owner] = nil
		end
	end
end)

-- Sukuna's domain slash. I've put this here as its shared for both sukuna's domains, so its not getting copied
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

if SERVER then return end

-- Handling nets

net.Receive("gJujutsu_cl_runDomainExpansion", function()
	local weapon = net.ReadEntity()
	
	if weapon:IsValid() then
		weapon:DomainExpansion()
	end
end)

concommand.Add( "jjk_domainClashes", function( ply, cmd, args )
	if CLIENT then return end
	PrintTable(gJujutsuDomainClashes)
end )
