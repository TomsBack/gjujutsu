AddCSLuaFile()

--
ENT.PrintName = "Mahoraga Wheel"
ENT.Author = "El Tomlino" 
ENT.Contact = "Steam"
ENT.Purpose = "Adaptation..."
ENT.Type = "anim"
ENT.Spawnable = false
ENT.Category = "Others"
ENT.DisableDuplicator = true
ENT.DoNotDuplicate = true
ENT.Animated = true
ENT.PhysgunDisabled = true
ENT.AutomaticFrameAdvance = true
ENT.RenderGroup	= RENDERGROUP_BOTH
--/me написал хук пуджа

function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "IdealPos")
end
function ENT:Initialize()
    if SERVER then
		self:SetModel("models/chromeda/wheel.mdl")
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
		self:SetModelScale( 1 )
	end
    self.angrotate = 0
    self.timerrotate = CurTime()
    self.timeradd1 = CurTime()
    self.timeradd2 = CurTime()
    self.timeradd3 = CurTime()
    self.timeradd4 = CurTime()
    self.timeradd5 = CurTime()
    self.timersound = CurTime()
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
	if SERVER and IsValid(self.Owner) and !self.Owner:Alive() then
		self:Remove()
	end
	if self != nil and IsValid(self) and IsValid(self.Owner) then
		local penis0 = self.Owner:GetAngles()
		penis0.p = 0
		penis0.r = 0
		local penis1 = penis0:Forward()
		local penis2 = penis0:Up()
		local ang = self.Owner:EyeAngles()
		local bone = "ValveBiped.Bip01_Head1"
		self:SetPos(self.Owner:GetBonePosition(self.Owner:LookupBone(bone)) + penis2 * 15)--+ penis1 * 5 + penis2 * 40)
		self:SetIdealPos(self.Owner:GetBonePosition(self.Owner:LookupBone(bone)) + penis2 * 15)--+ penis1 * 5 + penis2 * 40)
        if CurTime() > self.timerrotate then
            local adaptation = self.Owner:GetNetVar("Adaptation")
            if (adaptation == nil) then self.timerrotate = CurTime() + 0.015 return end
            for k, v in pairs(adaptation) do
                if IsValid(v[2]) then
                    if v[1] == self.Owner and self.Owner:GetNWInt("AdaptationProcent_"..v[2]:GetName(), 0) >= 1 and self.Owner:GetNWInt("AdaptationProcent_"..v[2]:GetName(), 0) <= 5 then
                        if CurTime() > self.timeradd1 then 
                            if SERVER and CurTime() > self.timersound then 
                                self.timersound = CurTime() + 2.5
                                self:EmitSound(Sound("gjujutsu_kaisen/sfx/sukuna/mahoraga_wheel_adaptation.wav"))
                            end
                            self.angrotate = self.angrotate - 1
                            timer.Simple(2.2, function()
                                self.timeradd1 = CurTime() + 5
                            end)
                        end
                        break
                    end
                    if v[1] == self.Owner and self.Owner:GetNWInt("AdaptationProcent_"..v[2]:GetName(), 0) >= 25 and self.Owner:GetNWInt("AdaptationProcent_"..v[2]:GetName(), 0) <= 30 then
                        if CurTime() > self.timeradd2 then 
                            if SERVER and CurTime() > self.timersound then 
                                self.timersound = CurTime() + 2.5
                                self:EmitSound(Sound("gjujutsu_kaisen/sfx/sukuna/mahoraga_wheel_adaptation.wav"))
                            end
                            self.angrotate = self.angrotate - 1
                            timer.Simple(2.2, function()
                                self.timeradd2 = CurTime() + 5
                            end)
                        end
                        break
                    end
                    if v[1] == self.Owner and self.Owner:GetNWInt("AdaptationProcent_"..v[2]:GetName(), 0) >= 50 and self.Owner:GetNWInt("AdaptationProcent_"..v[2]:GetName(), 0) <= 55 then
                        if CurTime() > self.timeradd3 then 
                            if SERVER and CurTime() > self.timersound then 
                                self.timersound = CurTime() + 2.5
                                self:EmitSound(Sound("gjujutsu_kaisen/sfx/sukuna/mahoraga_wheel_adaptation.wav"))
                            end
                            self.angrotate = self.angrotate - 1
                            timer.Simple(2.2, function()
                                self.timeradd3 = CurTime() + 5
                            end)
                        end
                        break
                    end
                    if v[1] == self.Owner and self.Owner:GetNWInt("AdaptationProcent_"..v[2]:GetName(), 0) >= 75 and self.Owner:GetNWInt("AdaptationProcent_"..v[2]:GetName(), 0) <= 80 then
                        if CurTime() > self.timeradd4 then 
                            if SERVER and CurTime() > self.timersound then 
                                self.timersound = CurTime() + 2.5
                                self:EmitSound(Sound("gjujutsu_kaisen/sfx/sukuna/mahoraga_wheel_adaptation.wav"))
                            end
                            self.angrotate = self.angrotate - 1
                            timer.Simple(2.2, function()
                                self.timeradd4 = CurTime() + 5
                            end)
                        end
                        break
                    end
                    if v[1] == self.Owner and self.Owner:GetNWInt("AdaptationProcent_"..v[2]:GetName(), 0) >= 97 and self.Owner:GetNWInt("AdaptationProcent_"..v[2]:GetName(), 0) <= 99 then
                        if CurTime() > self.timeradd5 then 
                            if SERVER and CurTime() > self.timersound then 
                                self.timersound = CurTime() + 2.5
                                self:EmitSound(Sound("gjujutsu_kaisen/sfx/sukuna/mahoraga_wheel_adaptation.wav"))
                            end
                            self.angrotate = self.angrotate - 1
                            timer.Simple(2.2, function()
                                self.timeradd5 = CurTime() + 5
                            end)
                        end
                        break
                    end
                end
            end
            self.timerrotate = CurTime() + 0.015
        end
        self:SetAngles(Angle(0,ang.y+self.angrotate,ang.r))
	end
end
function ENT:Draw()
	if IsValid( self ) then
		self:DrawModel()
		self:SetPos(LerpVector(1, self.Owner:GetPos(), self:GetIdealPos())) 
	end
end

function ENT:OnRemove()
	if SERVER and IsValid(self) then
		self:Remove()
	end
end
