if SERVER then
    AddCSLuaFile("shared.lua")
end
--
ENT.PrintName = "Gojo21412 Blue"
ENT.Author = "Darli214ng" 
ENT.Contact = "Ste1244am"
ENT.Purpose = "Bl4214ue!"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.Category = "Domain Expansio42314ns"
ENT.DisableDuplicator = true
ENT.DoNotDuplicate = true
ENT.Animated = true
ENT.PhysgunDisabled = true
ENT.AutomaticFrameAdvance = true
ENT.RenderGroup	= RENDERGROUP_BOTH
ENT.DamageExceptions = {
    ["npc_monk"] = DMG_GENERIC,
    ["npc_strider"] = DMG_GENERIC,
    ["npc_alyx"] = DMG_GENERIC,
    ["npc_barney"] = DMG_GENERIC,
    ["npc_mossman"] = DMG_GENERIC,
    ["npc_gman"] = DMG_GENERIC,
	["npc_rollermine"] = DMG_BLAST,
	["npc_antlionguard"] = DMG_GENERIC,
	["npc_vortigaunt"] = DMG_GENERIC,
	["VortigauntSlave"] = DMG_GENERIC,
	["npc_combinegunship"] = DMG_GENERIC,
	["npc_combinedropship"] = DMG_CRUSH,
	["npc_helicopter"] = DMG_AIRBOAT
}
--/me написал хук пуджа
function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "IdealPos")
end

function ENT:MovementThink(ply, mv)
	if ply ~= self:GetOwner() and not game.SinglePlayer() then return end

	local owner = self:GetOwner()
	local ownerPos
	local angles
	local fixangle
	local ang
	if game.SinglePlayer() then
		ownerPos = owner:GetPos()
		angles = owner:GetAngles()
	else
		ownerPos = mv:GetOrigin()
		angles = owner:GetAngles()
	end
	angles.x = 0
	angles:RotateAroundAxis(owner:GetRight(), -2)

	local finalPos = ownerPos
	
	finalPos = self:GetPos() + self.aimVector * 40


	self:SetNetworkOrigin(finalPos)
end

function ENT:Initialize()
	local owner = self:GetOwner()
	self:SetOwner(owner)
	self.aimVector = owner:GetAimVector()
	local ang = self.Owner:GetAimVector():Angle()
	self.penis0 = self.Owner:GetAimVector():Angle()
	self:SetAngles(Angle(ang.x+90,ang.y,ang.z+90))
	local penis0 = self.Owner:GetAngles()
	penis0.p = 0
	penis0.r = 0
	local penis1 = penis0:Right()
	local penis2 = penis0:Up()
	local penis3 = penis0:Forward()
	local thinkName = "gJujutsu_Dismantel" .. tostring(owner) .. tostring(self)
	self:SetPos(owner:WorldSpaceCenter() + penis2 * 30 + penis1 * -350 + penis3 * 100)--+ penis1 * 5 + penis2 * 40)
	hook.Add("FinishMove", thinkName, function(ply, mv)
		if !IsValid(self) or !IsValid(owner) then hook.Remove("FinishMove", thinkName) return end
		if not game.SinglePlayer() then
			self:MovementThink(ply, mv)
		end
	end)
	self.touchedents = {}
    if SERVER then
		local SteamIDForTimer = self.Owner:SteamID64()
		self:SetModel("models/chromeda/cleave.mdl")
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self:DrawShadow( false )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_NONE)
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:EnableGravity(false)
			phys:EnableMotion(false)
		end
		self:SetModelScale( 12 )
		timer.Create("Deleting".. tostring(self), 5, 1, function()
			if IsValid(self) then
				self:Remove()
			end
		end)
	end
end

function ENT:CanTool( ply, trace, mode, tool, button )
	return false
end

function ENT:Think()
	self:RemoveAllDecals()
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableGravity(false)
		phys:EnableMotion(false)
	end
	local owner = self:GetOwner()
	local penis = self.penis0:Forward()
	local penis22 = self.penis0:Right()
	local pos1 = self:GetPos() + penis * 1 + penis22 * 350
	local endpos1 = self:GetPos() + penis * 1.1 + penis22 * 350
	local mins1, maxs1 = Vector(-25,-350,-10), Vector(25,350,10)
	self.TableBox2 = {{pos1,endpos1,mins1,maxs1},{endpos1,pos1,mins1,maxs1}}
	local tr1 = util.TraceHull( {
		start = pos1,
		endpos = endpos1,
		filter = {owner},
		mins = mins1, 
		maxs = maxs1,
		mask = MASK_SHOT_HULL,
		ignoreworld = true
	} )
	if game.SinglePlayer() then
		self:MovementThink()
	end
	if SERVER and IsValid(tr1.Entity) and !self.touchedents[tr1.Entity] then
		self.touchedents[tr1.Entity] = true
		local ownerPos = owner:GetPos()
		local eyePos = owner:EyePos()
		local aimVector = owner:GetAimVector()

		local force = aimVector * 50000

		local damageInfo = DamageInfo()
		damageInfo:SetDamageType(5)
		if owner:IsValid() then damageInfo:SetAttacker(owner) end
		if self:IsValid() then damageInfo:SetInflictor(self) end
		damageInfo:SetDamage(5000)
		damageInfo:SetDamageForce(force)

		owner:EmitSound(Sound("misc/cloth_whoosh_1.wav"))
		owner:EmitSound(Sound("sukuna/sfx/dismantle_slash.wav"))


		owner:LagCompensation(true)

				
		local customDamageType = self.DamageExceptions[tr1.Entity:GetClass()]
				
		if customDamageType ~= nil then
			damageInfo:SetDamageType(customDamageType)
		else
			damageInfo:SetDamageType(5)
		end
		if owner:IsValid() then damageInfo:SetAttacker(owner) end
		if self:IsValid() then damageInfo:SetInflictor(self) end
		damageInfo:SetDamage(1000)
		damageInfo:SetDamageForce(force)

		tr1.Entity:TakeDamageInfo(damageInfo)

		tr1.Entity:EmitSound(Sound("sukuna/sfx/slash_prop_hit1.wav"))
				
		if tr1.Entity:gebLib_IsPerson() then
			tr1.Entity:EmitSound(Sound("sukuna/sfx/slash_body_hit" .. math.random(1, 2) .. ".wav"))
		end
				
		if tr1.Entity:gebLib_IsProp() then
			tr1.Entity:SetVelocity(force)
					
			local phys = tr1.Entity:GetPhysicsObject()
					
			if phys:IsValid() then
				phys:SetVelocity(force)
			end
					
			SukunaPropCut(owner, tr1.Entity, -180)
		end
		owner:LagCompensation(false)
	end
	local curTime = CurTime()
    if SERVER then
        self:NextThink(curTime)
        return true
    end
end

function ENT:Draw()
	self:DrawModel()
    if GetConVar("gjujutsu_show_hitboxes"):GetBool() and self.TableBox2 != nil then
		local table1 = self.TableBox2[1]
		local table2 = self.TableBox2[2]
		local cmins, cmaxs = table1[3],table1[4]
		local cpos, cang = table1[1], (table1[1] - table1[2]):GetNormalized():Angle()
		render.DrawWireframeBox(cpos, cang, cmins, cmaxs, Color(255,255,255,255), true)
		table1 = table2
		cmins, cmaxs = table1[3],table1[4]
		cpos, cang = table1[1], (table1[1] - table1[2]):GetNormalized():Angle()
		render.DrawWireframeBox(cpos, cang, cmins, cmaxs, Color(255,255,255,255), true)
	end
end

function ENT:OnRemove()
	if SERVER and IsValid(self) then
		self.touchedents = {}
		self:Remove()
	end
end