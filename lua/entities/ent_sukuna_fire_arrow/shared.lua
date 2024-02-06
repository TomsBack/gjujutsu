AddCSLuaFile()

--
ENT.PrintName = "Fuga"
ENT.Author = "Darling" 
ENT.Contact = "Steam"
ENT.Purpose = "Fire Arrow!"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.Category = "gjujutsu"
ENT.DisableDuplicator = true
ENT.DoNotDuplicate = true
ENT.Animated = true
ENT.PhysgunDisabled = true
ENT.AutomaticFrameAdvance = true
ENT.RenderGroup	= RENDERGROUP_BOTH

ENT.FireArrowSpeed = 50
--/me написал хук пуджа
function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "IdealPos")
end
function ENT:Initialize()
	self:SetOwner(self.Owner)
	local ang = self.Owner:GetAimVector():Angle()
	self:SetAngles(Angle(ang.z,ang.y+90,ang.x))
    if SERVER then
		local SteamIDForTimer = self.Owner:SteamID64()
		self:SetModel("models/chromeda/arrow.mdl")
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self:DrawShadow( false )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_NONE)
		self:ResetSequence(self:LookupSequence( "Stretched" ))
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:EnableGravity(false)
			phys:EnableMotion(false)
		end
		self:SetModelScale( 1 )
		local penis0 = self.Owner:GetAngles()
		penis0.p = 0
		penis0.r = 0
		local penis1 = penis0:Right()
		local penis2 = penis0:Up()
		local bone = "ValveBiped.Bip01_R_Finger12"
		self:SetPos(self.Owner:GetBonePosition(self.Owner:LookupBone(bone)) + penis2 * 57.5 + penis1 * 10)--+ penis1 * 5 + penis2 * 40)

		timer.Create("MovePurple22"..SteamIDForTimer, 0, 1, function()
			if IsValid(self) and IsValid(self.Owner) then
				local tr = self.Owner:GetEyeTrace()
				local dir = (tr.HitPos - self.Owner:EyePos()):GetNormalized()
				timer.Create("MoveForward"..SteamIDForTimer, 0, 0, function()
					if IsValid(self) and IsValid(self.Owner) then
						local speed = self.FireArrowSpeed
						local movement = dir * speed
						local newPos = self:GetPos() + movement
						self:SetPos(newPos)--+ penis1 * 5 + penis2 * 40)
						self:SetIdealPos(newPos)--+ penis1 * 5 + penis2 * 40)
					end
					local penis0 = self:GetAngles()
					penis0.p = 0
					penis0.r = 0
					local penis = penis0:Forward()
					local penis22 = penis0:Right()
					local pos1 = self:GetPos() + penis * 0 + penis22 * -10
					local endpos1 = self:GetPos() + penis * 0.1 + penis22 * -10
					local mins1, maxs1 = Vector(-10,-25,-5), Vector(10,25,15)
					self.TableBox2 = {{pos1,endpos1,mins1,maxs1},{endpos1,pos1,mins1,maxs1}}
					local tr1 = util.TraceHull( {
						start = pos1,
						endpos = endpos1,
						filter = {self.Owner},
						mins = mins1, 
						maxs = maxs1,
						mask = MASK_SHOT_HULL,
						ignoreworld = true
					} )
					if IsValid(self) then
						if IsValid(tr1.Entity) then
							if ( tr1.Entity ~= self.Owner and tr1.Entity ~= self ) and ( tr1.Entity:IsRagdoll() or tr1.Entity:IsNPC() or tr1.Entity:IsNextBot() or tr1.Entity:IsPlayer() or tr1.Entity:GetClass() == "prop_physics") then
								if tr1.Entity:IsNPC() then
									local oldvel = tr1.Entity:GetVelocity()
									tr1.Entity:TakeDamage(30)
									tr1.Entity:Ignite(30)
									local newvel = tr1.Entity:GetVelocity()
									tr1.Entity:SetVelocity( oldvel - newvel )
								elseif tr1.Entity:IsPlayer() and !tr1.Entity:GetNWBool("AdaptationPlayer_"..self.Owner:GetName(), false) then
									local oldvel = tr1.Entity:GetVelocity()
									tr1.Entity:TakeDamage(30)
									tr1.Entity:Ignite(30)
									local newvel = tr1.Entity:GetVelocity()
									tr1.Entity:SetVelocity( oldvel - newvel )
				
								elseif tr1.Entity:GetClass() == 'prop_physics' or tr1.Entity:IsNextBot() then
									tr1.Entity:TakeDamage(30)
									tr1.Entity:Ignite(30)
								end
							end
							if ( tr1.Entity ~= self.Owner and tr1.Entity ~= self ) and (tr1.Entity:GetClass() == "ent_sukuna_domain_expansion" or tr1.Entity:GetClass() == "ent_sukuna_domain_expansion3") then
								if SERVER then
									tr1.Entity:TakeDamage(1000)
									tr1.Entity:Ignite(30)
								end
							end
						end
						if IsValid(tr1.Entity) then
							if tr1.Entity ~= self.Owner and tr1.Entity ~= self and ( tr1.Entity:IsPlayer() or tr1.Entity:IsRagdoll() or tr1.Entity:GetClass() == "prop_physics") then
								local oldvel = tr1.Entity:GetVelocity()
								tr1.Entity:TakeDamage(30)
								tr1.Entity:Ignite(30)
								local newvel = tr1.Entity:GetVelocity()
								tr1.Entity:SetVelocity( oldvel - newvel )
							end
						end
					end
				end)
			end
		end)
		timer.Create("DeletePurple"..SteamIDForTimer,5,1, function()
			if IsValid(self) then
				self:Remove()
				timer.Remove("MoveForward"..SteamIDForTimer)
				timer.Remove("MovePurple22"..SteamIDForTimer)
				timer.Remove("DeletePurple"..SteamIDForTimer)
			end
		end)
	end
	self.penis0 = self.Owner:GetAimVector():Angle()
	self.SteamIDForTimer = self.Owner:SteamID64()
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
	if SERVER and !self.Owner:Alive() then
		self:Remove()
		timer.Remove("MoveForwardArrow"..self.SteamIDForTimer)
	end
    local penis = self.penis0:Forward()
    local penis22 = self.penis0:Right()
    local pos1 = self:GetPos() + penis * -10 + penis22 * -0.01
    local endpos1 = self:GetPos() + penis * -10.1 + penis22 * -0.01
    local mins1, maxs1 = Vector(-20,-5,-1), Vector(20,5,10)
    self.TableBox2 = {{pos1,endpos1,mins1,maxs1},{endpos1,pos1,mins1,maxs1}}
	local tr1 = util.TraceHull( {
		start = pos1,
		endpos = endpos1,
		filter = {self.Owner},
		mins = mins1, 
		maxs = maxs1,
		mask = MASK_SHOT_HULL,
		ignoreworld = true
	} )
end

function ENT:Draw()
	self:DrawModel()
	self:SetPos(LerpVector(1, self:GetPos(), self:GetIdealPos())) 
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
		self:Remove()
	end
end