local PLAYER = FindMetaTable('Player')

function PLAYER:addAdaptation(Attacker)
	table.insert(self:GetNetVar("Adaptation"), {self, Attacker, false})
    table.insert(Attacker:GetNetVar("Adaptation"), {self, Attacker, false})
    Attacker:SetNetVar("Adaptation", Attacker:GetNetVar("Adaptation"))
    self:SetNetVar("Adaptation", self:GetNetVar("Adaptation"))
    self:SetNWInt("AdaptationProcent_"..Attacker:GetName(), 0)
    self:SetNWInt("AdaptationProcentDouble_"..Attacker:GetName(), 1)
    self:SetNWBool("AdaptationPokaz_"..Attacker:GetName(), true)
    timer.Create("addAdaptationProcent_"..self:GetName().."_"..Attacker:GetName(), 3, 0, function()
           for k, v in pairs(self:GetNetVar("Adaptation")) do
               if v[1] == self then
                   if v[2] == Attacker then
                       self:SetNWInt("AdaptationProcent_"..Attacker:GetName(), self:GetNWInt("AdaptationProcent_"..Attacker:GetName(), 0) + self:GetNWInt("AdaptationProcentDouble_"..Attacker:GetName(), 1))

                       if self:GetNWInt("AdaptationProcent_"..Attacker:GetName(), 0) >= 100 then
						self:SetNWInt("AdaptationProcent_"..Attacker:GetName(), 100)
                           timer.Destroy("addAdaptationProcent_"..self:GetName().."_"..Attacker:GetName())
                        self:SetNWBool("AdaptationPlayer_"..Attacker:GetName(), true)
                        Attacker:SetNWBool("AdaptationPlayer_"..self:GetName(), true)
                       end
                   end
               end
           end
    end)
end

hook.Add("PlayerShouldTakeDamage", "AdaptationDamage", function(p, a)
	if p:GetActiveWeapon():GetClass() == "gjujutsu_sukuna" then
		if p:GetActiveWeapon().mahoragawheel == true then
			local adaptation = p:GetNetVar("Adaptation")

			if adaptation == nil then
				p:addAdaptation(a)
				return
				else
				for k, v in pairs(adaptation) do
					if v[1] == p then
						if v[2] == a then
							if p:GetNWInt("AdaptationProcentDouble_"..v[2]:GetName(), 1) >= 3 then return end
							p:SetNWInt("AdaptationProcentDouble_"..v[2]:GetName(), p:GetNWInt("AdaptationProcentDouble_"..v[2]:GetName(), 1) + 1)
							return
						end
					end
				end
				p:addAdaptation(a)
			end
		end
	end
end)

hook.Add("PlayerDeath", "AdaptationDeath", function(ply)
    local adaptation = ply:GetNetVar("Adaptation")

    if (adaptation == nil) then return end

    for k, v in pairs(adaptation) do
        if v[1] == ply then
            ply:SetNWBool("AdaptationPokaz_"..v[2]:GetName(), false)
            timer.Destroy("addAdaptationProcent_"..ply:GetName().."_"..v[2]:GetName())
            ply:SetNWInt("AdaptationProcent_"..v[2]:GetName(), 0)
            ply:SetNWInt("AdaptationProcentDouble_"..v[2]:GetName(), 1)
			ply:SetNWBool("AdaptationPlayer_"..v[2]:GetName(), false)
			v[2]:SetNWBool("AdaptationPlayer_"..ply:GetName(), false)
            table.remove(ply:GetNetVar("Adaptation"), k)
            table.remove(v[2]:GetNetVar("Adaptation"), k)
        end

        if v[2] == ply then
            v[1]:SetNWBool("AdaptationPokaz_"..ply:GetName(), false)
            timer.Destroy("addAdaptationProcent_"..v[1]:GetName().."_"..ply:GetName())
            v[1]:SetNWInt("AdaptationProcent_"..ply:GetName(), 0)
            v[1]:SetNWInt("AdaptationProcentDouble_"..ply:GetName(), 1)
			ply:SetNWBool("AdaptationPlayer_"..v[1]:GetName(), false)
			v[1]:SetNWBool("AdaptationPlayer_"..ply:GetName(), false)
            table.remove(ply:GetNetVar("Adaptation"), k)
            table.remove(v[1]:GetNetVar("Adaptation"), k)
        end
    end
end)

hook.Add("PlayerDisconnected", "AdaptationDisconnected", function(ply)
    local adaptation = ply:GetNetVar("Adaptation")

    if (adaptation == nil) then return end

    for k, v in pairs(adaptation) do
        if v[1] == ply then
            ply:SetNWBool("AdaptationPokaz_"..v[2]:GetName(), false)
            timer.Destroy("addAdaptationProcent_"..ply:GetName().."_"..v[2]:GetName())
            ply:SetNWInt("AdaptationProcent_"..v[2]:GetName(), 0)
            ply:SetNWInt("AdaptationProcentDouble_"..v[2]:GetName(), 1)
			ply:SetNWBool("AdaptationPlayer_"..v[2]:GetName(), false)
			v[2]:SetNWBool("AdaptationPlayer_"..ply:GetName(), false)
            table.remove(ply:GetNetVar("Adaptation"), k)
            table.remove(v[2]:GetNetVar("Adaptation"), k)
        end

        if v[2] == ply then
            v[1]:SetNWBool("AdaptationPokaz_"..ply:GetName(), false)
            timer.Destroy("addAdaptationProcent_"..v[1]:GetName().."_"..ply:GetName())
            v[1]:SetNWInt("AdaptationProcent_"..ply:GetName(), 0)
            v[1]:SetNWInt("AdaptationProcentDouble_"..ply:GetName(), 1)
			ply:SetNWBool("AdaptationPlayer_"..v[1]:GetName(), false)
			v[1]:SetNWBool("AdaptationPlayer_"..ply:GetName(), false)
            table.remove(ply:GetNetVar("Adaptation"), k)
            table.remove(v[1]:GetNetVar("Adaptation"), k)
        end
    end
end)

hook.Add("PlayerInitialSpawn", "AdaptationInit", function(ply)
    timer.Simple(.5, function()
        ply:SetNetVar("Adaptation", {})
    end)
end)
