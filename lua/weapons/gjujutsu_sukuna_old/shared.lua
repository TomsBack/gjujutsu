if SERVER then
    AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName = "Sukuna's Vessel"
SWEP.Author = "darling"
SWEP.Instructions = "Sukuna's Vessel"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Category = "gJujutsu"
SWEP.HoldType = "normal"
SWEP.UseHands = false

SWEP.ViewModel = 'models/chromeda/arrow.mdl'
SWEP.WorldModel = 'models/chromeda/arrow.mdl'

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.domainActive   = false

SWEP.Abilities = {
	[AbilityKey.Ability3] = "Slashes",
	[AbilityKey.Ability4] = "FireArrow",
	[AbilityKey.Ability5] = nil,
	[AbilityKey.Ability6] = "MahoragaWheelActive",
	[AbilityKey.Ability7] = "Dismantle",
	[AbilityKey.Ability8] = "ReversedCursedTechnic",
	[AbilityKey.Ultimate] = "DomainExpansionActivate",
	[AbilityKey.Taunt] = nil,
}

local ActIndex = {
	[ "pistol" ]		= ACT_HL2MP_IDLE_PISTOL,
	[ "smg" ]			= ACT_HL2MP_IDLE_SMG1,
	[ "grenade" ]		= ACT_HL2MP_IDLE_GRENADE,
	[ "ar2" ]			= ACT_HL2MP_IDLE_AR2,
	[ "shotgun" ]		= ACT_HL2MP_IDLE_SHOTGUN,
	[ "rpg" ]			= ACT_HL2MP_IDLE_RPG,
	[ "physgun" ]		= ACT_HL2MP_IDLE_PHYSGUN,
	[ "crossbow" ]		= ACT_HL2MP_IDLE_CROSSBOW,
	[ "melee" ]			= ACT_HL2MP_IDLE_MELEE,
	[ "slam" ]			= ACT_HL2MP_IDLE_SLAM,
	[ "normal" ]		= ACT_HL2MP_IDLE,
	[ "fist" ]			= ACT_HL2MP_IDLE_FIST,
	[ "melee2" ]		= ACT_HL2MP_IDLE_MELEE2,
	[ "passive" ]		= ACT_HL2MP_IDLE_PASSIVE,
	[ "knife" ]			= ACT_HL2MP_IDLE_KNIFE,
	[ "duel" ]			= ACT_HL2MP_IDLE_DUEL,
	[ "camera" ]		= ACT_HL2MP_IDLE_CAMERA,
	[ "magic" ]			= ACT_HL2MP_IDLE_MAGIC,
	[ "revolver" ]		= ACT_HL2MP_IDLE_REVOLVER,
	[ "sukunaanims" ]		= ACT_HL2MP_IDLE,
    [ "sukunaanims2" ]		= ACT_HL2MP_IDLE,
    [ "sukunaanims3" ]		= ACT_HL2MP_IDLE
}

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "CursedEnergy")
    self:NetworkVar("Float", 1, "MindHealth")
    self:NetworkVar("Float", 2, "MalevolentShrineDelay" )
    self:NetworkVar("Float", 3, "SlashsDelay" )
    self:NetworkVar("Float", 4, "SingleSlashDelay" )
    self:NetworkVar("Float", 5, "FireArrowDelay" )
    self:NetworkVar("Float", 6, "SlashsDelay2" )
	self:NetworkVar("Float", 7, "NextEvent")

    self:NetworkVar("Entity", 0, "MahoragaWheel" )
	self:NetworkVar("Entity", 1, "DomainExpansion")

	self:NetworkVar("String", 0, "Event")
end

function SWEP:SetWeaponHoldType( t )
	
	t = string.lower( t )
	local index = ActIndex[ t ]
	
	if ( index == nil ) then
		Msg( "SWEP:SetWeaponHoldType - ActIndex[ \"" .. t .. "\" ] isn't set! (defaulting to normal)\n" )
		t = "normal"
		index = ActIndex[ t ]
	end
    if self != nil and IsValid(self) and self.Owner != nil and IsValid(self.Owner) then
        if ( t == "sukunaanims" ) then
            self.ActivityTranslate = {}
            self.ActivityTranslate[ ACT_MP_STAND_IDLE ]					= self.Owner:GetSequenceActivity(self.Owner:LookupSequence("sukuna_idle_anim"))
            self.ActivityTranslate[ ACT_MP_WALK ] = ACT_HL2MP_IDLE + 1
            self.ActivityTranslate[ ACT_MP_RUN ] = ACT_HL2MP_RUN_FAST
            self.ActivityTranslate[ ACT_MP_CROUCH_IDLE ] = self.Owner:GetSequenceActivity(self.Owner:LookupSequence( "pose_ducking_01" ))
            self.ActivityTranslate[ ACT_MP_CROUCHWALK ] = index + 4
            self.ActivityTranslate[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = index + 5
            self.ActivityTranslate[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index + 6
            self.ActivityTranslate[ ACT_MP_RELOAD_STAND ] = self.Owner:GetSequenceActivity(self.Owner:LookupSequence( "sukuna_domain_anim" ))
            self.ActivityTranslate[ ACT_MP_RELOAD_CROUCH ] = self.Owner:GetSequenceActivity(self.Owner:LookupSequence( "sukuna_domain_anim" ))
            self.ActivityTranslate[ ACT_MP_JUMP ] = self.Owner:GetSequenceActivity(self.Owner:LookupSequence( "jump_slam" ))
            self.ActivityTranslate[ ACT_RANGE_ATTACK1 ] = index + 8
            self.ActivityTranslate[ ACT_MP_SWIM ] = index + 9
            elseif ( t == "sukunaanims2" ) then
            self.ActivityTranslate = {}
            self.ActivityTranslate[ ACT_MP_STAND_IDLE ]					= self.Owner:GetSequenceActivity(self.Owner:LookupSequence("sukuna_idle_anim"))
            self.ActivityTranslate[ ACT_MP_WALK ] = ACT_HL2MP_IDLE + 1
            self.ActivityTranslate[ ACT_MP_RUN ] = ACT_HL2MP_RUN_FAST
            self.ActivityTranslate[ ACT_MP_CROUCH_IDLE ] = self.Owner:GetSequenceActivity(self.Owner:LookupSequence( "pose_ducking_01" ))
            self.ActivityTranslate[ ACT_MP_CROUCHWALK ] = index + 4
            self.ActivityTranslate[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = index + 5
            self.ActivityTranslate[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index + 6
            self.ActivityTranslate[ ACT_MP_RELOAD_STAND ] = self.Owner:GetSequenceActivity(self.Owner:LookupSequence( "sukuna_fire_arrow" ))
            self.ActivityTranslate[ ACT_MP_RELOAD_CROUCH ] = self.Owner:GetSequenceActivity(self.Owner:LookupSequence( "sukuna_fire_arrow" ))
            self.ActivityTranslate[ ACT_MP_JUMP ] = self.Owner:GetSequenceActivity(self.Owner:LookupSequence( "jump_slam" ))
            self.ActivityTranslate[ ACT_RANGE_ATTACK1 ] = index + 8
            self.ActivityTranslate[ ACT_MP_SWIM ] = index + 9
            elseif ( t == "sukunaanims3" ) then
            self.ActivityTranslate = {}
            self.ActivityTranslate[ ACT_MP_STAND_IDLE ]					= self.Owner:GetSequenceActivity(self.Owner:LookupSequence("sukuna_idle_anim"))
            self.ActivityTranslate[ ACT_MP_WALK ] = ACT_HL2MP_IDLE + 1
            self.ActivityTranslate[ ACT_MP_RUN ] = ACT_HL2MP_RUN_FAST
            self.ActivityTranslate[ ACT_MP_CROUCH_IDLE ] = self.Owner:GetSequenceActivity(self.Owner:LookupSequence( "pose_ducking_01" ))
            self.ActivityTranslate[ ACT_MP_CROUCHWALK ] = index + 4
            self.ActivityTranslate[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = index + 5
            self.ActivityTranslate[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index + 6
            self.ActivityTranslate[ ACT_MP_RELOAD_STAND ] = self.Owner:GetSequenceActivity(self.Owner:LookupSequence( "sukuna_dismantel" ))
            self.ActivityTranslate[ ACT_MP_RELOAD_CROUCH ] = self.Owner:GetSequenceActivity(self.Owner:LookupSequence( "sukuna_dismantel" ))
            self.ActivityTranslate[ ACT_MP_JUMP ] = self.Owner:GetSequenceActivity(self.Owner:LookupSequence( "jump_slam" ))
            self.ActivityTranslate[ ACT_RANGE_ATTACK1 ] = index + 8
            self.ActivityTranslate[ ACT_MP_SWIM ] = index + 9
            else
            self.ActivityTranslate = {}
            self.ActivityTranslate[ ACT_MP_STAND_IDLE ]					= index
            self.ActivityTranslate[ ACT_MP_WALK ]						= index + 1
            self.ActivityTranslate[ ACT_MP_RUN ]						= index + 2
            self.ActivityTranslate[ ACT_MP_CROUCH_IDLE ]				= index + 3
            self.ActivityTranslate[ ACT_MP_CROUCHWALK ]					= index + 4
            self.ActivityTranslate[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= index + 5
            self.ActivityTranslate[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= index + 5
            self.ActivityTranslate[ ACT_MP_RELOAD_STAND ]				= index + 6
            self.ActivityTranslate[ ACT_MP_RELOAD_CROUCH ]				= index + 6
            self.ActivityTranslate[ ACT_MP_JUMP ]						= index + 7
            self.ActivityTranslate[ ACT_RANGE_ATTACK1 ]					= index + 8
            self.ActivityTranslate[ ACT_MP_SWIM ]						= index + 9
        end
    end
end

/*local whitelist = {
    ["STEAM_1:0:48301661"] = true,--
    ["STEAM_0:1:68507947"] = true,--
    ["STEAM_0:1:500568095"] = true,--
    ["STEAM_0:0:62896"] = true,--
    ["STEAM_0:0:44785019"] = true,--
    ["STEAM_0:0:657665641"] = true,--
    ["STEAM_0:0:199483252"] = true,--
    ["STEAM_0:0:48301661"] = true,--
    ["STEAM_0:0:447850191"] = true,
        ["STEAM_0:0:195508347"] = true,--
    ["STEAM_0:1:470642477"] = true,--
    ["STEAM_0:1:502307860"] = true,
        ["STEAM_0:1:566463524"] = true,
        ["STEAM_0:1:508498923"] = true,
}

hook.Add("PlayerSpawn", "Whitelist", function(ply)
	if whitelist[ply:SteamID()] then
		if ply != nil and IsValid(ply) then
			if !ply:GetNWBool( "WhitelistMessage") then
				ply:SendLua("chat.AddText(Color(255,0,0), '|',Color(255,255,255),'[JJK]' ,Color(255,0,0),'|',Color(255,255,255), ' - Access check...' )")
				timer.Simple(1,function()
					if ply != nil and IsValid(ply) then
						ply:SendLua("chat.AddText(Color(255,0,0), '|',Color(255,255,255),'[JJK]' ,Color(255,0,0),'|',Color(255,255,255), ' - Right! You have access to the game.' )")
					end
				end)
				ply:SetNWBool( "WhitelistMessage", true )
			end
		end
		else
		ply:SendLua("chat.AddText(Color(255,0,0), '|',Color(255,255,255),'[JJK]' ,Color(255,0,0),'|',Color(255,255,255), ' - Access check...' )")
		timer.Simple(0.25,function()
			if ply != nil and IsValid(ply) then
				ply:SendLua("chat.AddText(Color(255,0,0), '|',Color(255,255,255),'[JJK]' ,Color(255,0,0),'|',Color(255,255,255), ' - You dont have access to use JJK mod.' )")
				ply:Kill()
				ply:Freeze()
			end
		end)
	end
end)*/
local thirdperson_offset = GetConVar("gjujutsu_thirdperson_offset")
function SWEP:CalcView( ply, pos, ang, fov )
	if ply:GetViewEntity() ~= ply then return end	
	local convar = thirdperson_offset:GetString()
	local strtab = string.Split(convar, ",")
	local offset = Vector(strtab[1], strtab[2], strtab[3])
	offset:Rotate(ang)
	
	local trace = util.TraceHull( {
		start = pos,
		endpos = pos - ang:Forward() * 100,
		filter = { ply:GetActiveWeapon(), ply, ply:GetVehicle() },
		mins = Vector( -4, -4, -4 ),
		maxs = Vector( 4, 4, 4 ),
	} )
	
	if ( trace.Hit ) then pos = trace.HitPos else pos = trace.HitPos end
	return pos + offset,ang
end
hook.Add( "ShouldDrawLocalPlayer", "DrawSukunaInThirdPerson", function()
    if (  LocalPlayer():IsValid() and  LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "gjujutsu_sukuna" and !LocalPlayer():InVehicle() and LocalPlayer():Alive() and LocalPlayer():GetViewEntity() == LocalPlayer() ) then return true end
end )
function SWEP:Initialize()
    self.domainActive = false
    self.slashescd = false
    self:SetCursedEnergy(math.max(0, self:GetCursedEnergy() + 2500))
    self:SetMindHealth(100)
    self.wasset = false

	-- Crude hack before rewriting sukuna
	timer.Simple(0, function()
		local owner = self:GetOwner()

		if not owner:IsValid() then return end

		owner:SetModel(Model("models/moon/Ryomen_Sukuna/Ryomen_Sukuna.mdl"))
		print("setting model")
	end)
end
function SWEP:Deploy()
    if IsValid(self.Owner) then
        self:SetHoldType("sukunaanims")
		
        self.Owner:SetModel("models/moon/Ryomen_Sukuna/Ryomen_Sukuna.mdl")
        self.mahoragawheel = false
        self.SteamIDForTimer = self.Owner:SteamID64()
        if self.wasset == false then
            self.wasset = true
            self.Owner:SetHealth(3000)
        end
    end
end

if CLIENT then
    local ability_boxic1 = Material("hud/ability_box_black2.png","smooth")
    local ability_boxic2 = Material("hud/ability_box_white.png","smooth")
    local general_boxic = Material("hud/general_box.png","smooth")
    local healthbox = Material("hud/health.png","smooth")
    function SWEP:DrawHUD()
        if self != nil and IsValid(self) then
            local height = ScrH()
            local width = ScrW()
            local mult = ScrW() / 1920
            local upperindex = -1
            if ScrW() > 2000 then 
                upperindex = -0.40
            end
            DisableClipping(true)
            cam.Start3D(nil, nil, 65, ScrW()*0.001, ScrH() * .462, ScrW()/2, ScrH() * .7)
                local opacity = 255*80
        
                local up, right, forward = EyeAngles():Up(), EyeAngles():Right(), EyeAngles():Forward()
                local ang = EyeAngles()
                ang:RotateAroundAxis(up, 180)
                ang:RotateAroundAxis(right, 114.5)
                ang:RotateAroundAxis(forward, -90)
                local pos = EyePos() + (forward * 7) + (up * upperindex) + (right * -3 )
        
                cam.Start3D2D(pos, ang, 0.011) 
                    surface.SetDrawColor( 255, 0, 0, 255)
                    surface.SetMaterial(healthbox)
                    surface.DrawTexturedRect(54.5, -70, math.Clamp(self.Owner:Health()/self.Owner:GetMaxHealth() * 100,0,100) * 5.16, 40)
                    surface.SetDrawColor( 0, 0, 255, 255)
                    surface.DrawTexturedRect(35.5, -37, math.Clamp(self.Owner:Armor()/self.Owner:GetMaxArmor() * 100,0,100) * 5.16, 40)
                    surface.SetDrawColor( 145, 21, 19, 255)
                    surface.DrawTexturedRect(22, -4, math.Clamp(self:GetMindHealth(),0,100) * 5.16, 40)
                    draw.SimpleTextOutlined("Health "..self.Owner:Health().."/"..self.Owner:GetMaxHealth(), "gJujutsuFont2", 81, -47.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                    draw.SimpleTextOutlined("Armor "..self.Owner:Armor().."/"..self.Owner:GetMaxArmor(), "gJujutsuFont2", 60, -15.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                    draw.SimpleTextOutlined("Mind "..self:GetMindHealth().."/100", "gJujutsuFont2", 49, 18.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                    surface.SetDrawColor( 255, 255, 255, 255)
                    surface.SetMaterial(general_boxic)
                    surface.SetDrawColor( color_white )
                    surface.DrawTexturedRect(-100, -120, 663, 155)
                    DrawCircularBar(-32, -51,math.Clamp(self:GetCursedEnergy()/25,0,100),67, 9, 0,Color(59,199,255))
                    draw.SimpleTextOutlined(self:GetCursedEnergy().."/2500", "gJujutsuFont2", -88, -50, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                    local x, y = -100, -205
                    local oy = 11   
                    for k, v in pairs((self.Owner:GetNetVar("Adaptation") or {})) do
                        if v[1] == self.Owner then
                            y = oy + y
                            if IsValid(v[2]) then
                                if self.Owner:GetNWBool("AdaptationPokaz_"..v[2]:GetName(), false) == true then
                                    TextWithShadow(v[2]:GetName() .. " - Adaptation Progress:"..self.Owner:GetNWInt("AdaptationProcent_"..v[2]:GetName(), 0) .. "%", "gJujutsuFont1", x, y + y, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                                end
                            end
                        end
                    end
                cam.End3D2D()
            cam.End3D()
            DisableClipping(false)
            DisableClipping(true)
            cam.Start3D(nil, nil, 65, ScrW()*.6, ScrH() * .3, ScrW()/2, ScrH() * .7)
                local opacity = 255*80
        
                local up, right, forward = EyeAngles():Up(), EyeAngles():Right(), EyeAngles():Forward()
                local ang = EyeAngles()
                ang:RotateAroundAxis(up, 170)
                ang:RotateAroundAxis(right, 79.5)
                ang:RotateAroundAxis(forward, -98)
                local pos = EyePos() + (forward * 7) + (up * upperindex) + (right * -2.1 )
        
                cam.Start3D2D(pos, ang, 0.011) 
                    if CurTime() > self:GetMalevolentShrineDelay() then
                        surface.SetMaterial(ability_boxic1)
                        surface.SetDrawColor( color_white )
                        surface.DrawTexturedRect(11, 120, 400, 30)
                    end
                    surface.SetMaterial(ability_boxic2)
                    surface.SetDrawColor( color_white )
                    surface.DrawTexturedRect(11, 120, 400, 30)
                    if CurTime() > self:GetMalevolentShrineDelay() then
                        draw.SimpleTextOutlined("Domain Expansion: Malevolent Shrine", "gJujutsuFont3", 70, 136.5, color_white, 0, 1, 1, Color(0, 0, 0, 255))
                        draw.SimpleTextOutlined(string.upper(input.GetKeyName(GetConVar("gjujutsu_ultimate_key"):GetInt())), "gJujutsuFont3", 385.2, 137.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                        else
                        draw.SimpleTextOutlined("Domain Expansion: Malevolent Shrine", "gJujutsuFont3", 70, 136.5, Color(255,255,255,30), 0, 1, 1, Color(0, 0, 0, 255))
                        draw.SimpleTextOutlined(math.Round(self:GetMalevolentShrineDelay() - CurTime()), "gJujutsuFont3", 391.5, 136.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                    end
                    surface.SetMaterial(ability_boxic1)
                    surface.SetDrawColor( color_white )
                    surface.DrawTexturedRect(7, 80, 400, 30)
                    surface.SetMaterial(ability_boxic2)
                    surface.SetDrawColor( color_white )
                    surface.DrawTexturedRect(7, 80, 400, 30)
                    draw.SimpleTextOutlined(string.upper(input.GetKeyName(GetConVar("gjujutsu_ability8_key"):GetInt())), "gJujutsuFont3", 381.2, 97, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                    if self.ReversCursedTechnic == true then
                        draw.SimpleTextOutlined("Reverse Cursed Technique (Active)", "gJujutsuFont3", 65, 96.5, color_white, 0, 1, 1, Color(0, 0, 0, 255))
                        else
                        draw.SimpleTextOutlined("Reverse Cursed Technique (Inctive)", "gJujutsuFont3", 62.5, 96.5, color_white, 0, 1, 1, Color(0, 0, 0, 255))
                    end
                    surface.SetMaterial(ability_boxic1)
                    surface.SetDrawColor( color_white )
                    surface.DrawTexturedRect(3, 40, 400, 30)
                    surface.SetMaterial(ability_boxic2)
                    surface.SetDrawColor( color_white )
                    surface.DrawTexturedRect(3, 40, 400, 30)
                    draw.SimpleTextOutlined(string.upper(input.GetKeyName(GetConVar("gjujutsu_ability7_key"):GetInt())), "gJujutsuFont3", 376.2, 57, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                    --if self.sixeyes == true then
                        draw.SimpleTextOutlined("Dismantle", "gJujutsuFont3", 285.5, 56.5, color_white, 0, 1, 1, Color(0, 0, 0, 255))
                        --else
                        --draw.SimpleTextOutlined("Six Eyes Mode (Inactive)", "gJujutsuFont3", 155.5, 56.5, color_white, 0, 1, 1, Color(0, 0, 0, 255))
                    --end
                    surface.SetMaterial(ability_boxic1)
                    surface.SetDrawColor( color_white )
                    surface.DrawTexturedRect(-1, 0, 400, 30)
                    surface.SetMaterial(ability_boxic2)
                    surface.SetDrawColor( color_white )
                    surface.DrawTexturedRect(-1, 0, 400, 30)
                    draw.SimpleTextOutlined(string.upper(input.GetKeyName(GetConVar("gjujutsu_ability6_key"):GetInt())), "gJujutsuFont3", 373.2, 17, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                    if self.mahoragawheel == true then
                        draw.SimpleTextOutlined("General Mahoraga: Adaptation (Active)", "gJujutsuFont3", 42, 16.5, color_white, 0, 1, 1, Color(0, 0, 0, 255))
                        else
                        draw.SimpleTextOutlined("General Mahoraga: Adaptation (Inactive)", "gJujutsuFont3", 31, 16.5, color_white, 0, 1, 1, Color(0, 0, 0, 255))
                    end
                    if CurTime() > self:GetSlashsDelay() then
                        surface.SetMaterial(ability_boxic1)
                        surface.SetDrawColor( color_white )
                        surface.DrawTexturedRect(-5, -40, 400, 30)
                    end
                    surface.SetMaterial(ability_boxic2)
                    surface.SetDrawColor( color_white )
                    surface.DrawTexturedRect(-5, -40, 400, 30)
                    if CurTime() > self:GetSlashsDelay() then
                        draw.SimpleTextOutlined("Cleave", "gJujutsuFont3", 300.5, -24.5, color_white, 0, 1, 1, Color(0, 0, 0, 255))
                        draw.SimpleTextOutlined(string.upper(input.GetKeyName(GetConVar("gjujutsu_ability3_key"):GetInt())), "gJujutsuFont3", 369.5, -24, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                        else
                        draw.SimpleTextOutlined("Cleave", "gJujutsuFont3", 300.5, -24.5, Color(255,255,255,30), 0, 1, 1, Color(0, 0, 0, 255))
                        draw.SimpleTextOutlined(math.Round(self:GetSlashsDelay() - CurTime()), "gJujutsuFont3", 376, -24, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                    end
                    if CurTime() > self:GetFireArrowDelay() then
                        surface.SetMaterial(ability_boxic1)
                        surface.SetDrawColor( color_white )
                        surface.DrawTexturedRect(-9, -80, 400, 30)
                    end
                    surface.SetMaterial(ability_boxic2)
                    surface.SetDrawColor( color_white )
                    surface.DrawTexturedRect(-9, -80, 400, 30)
                    if CurTime() > self:GetFireArrowDelay() then
                        draw.SimpleTextOutlined("[Open]: Fire Arrow", "gJujutsuFont3", 190.5, -64.5, color_white, 0, 1, 1, Color(0, 0, 0, 255))
                        draw.SimpleTextOutlined(string.upper(input.GetKeyName(GetConVar("gjujutsu_ability4_key"):GetInt())), "gJujutsuFont3", 366, -64, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                        else
                        draw.SimpleTextOutlined("[Open]: Fire Arrow", "gJujutsuFont3", 190.5, -64.5, Color(255,255,255,30), 0, 1, 1, Color(0, 0, 0, 255))
                        draw.SimpleTextOutlined(math.Round(self:GetFireArrowDelay() - CurTime()), "gJujutsuFont3", 372, -64, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
                    end
                cam.End3D2D()
            cam.End3D()
            DisableClipping(false)
        end
    end
end
hook.Add( "HUDShouldDraw", "JJKSukunaHud", function(elem)
	if IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "gjujutsu_sukuna" and (elem == "CHudHealth" or elem == "CHudAmmo" or elem == "CHudBattery" or elem == "CLHudSecondaryAmmo") then
		return false
	end
end)


local timengforparticle = 0
function SWEP:DomainExpansionActivate()
	if self:GetDomainExpansion():IsValid() then return end
	local owner = self:GetOwner()

    self.MalevolentShrineDelay = self.MalevolentShrineDelay or CurTime()
    if owner:OnGround() and self:GetCursedEnergy() >= 1000 and CurTime() > self:GetMalevolentShrineDelay() then
        local lastangles = owner:GetAimVector():Angle()
        lastangles.p = 0
        lastangles.r = 0
        owner:SetEyeAngles(lastangles)
        if CLIENT and owner:PredictedOrDifferentPlayer() then
            SUKUNA_DomainExpansionCinematic(owner)
        end
        self:SetMalevolentShrineDelay(CurTime() + 1)
        if owner:KeyDown(IN_SPEED) then
            self:SetCursedEnergy(math.max(0, self:GetCursedEnergy() - 1000))
            timer.Create ("DomainAnimationFix"..self.SteamIDForTimer,0,1, function()
                self:SetHoldType("sukunaanims")
                owner:SetAnimation(PLAYER_RELOAD)
            end)
            if SERVER then
                for k, v in pairs( ents.GetAll()) do
                    if v:IsPlayer() then
                        net.Start( "sukunatimerreset" )
                        net.Send(v) 
                    end
                end
                local domain_expansion_sound = Sound("gjujutsu_kaisen/sukuna/domain_expansion_sound2.wav")
                self.domainActive = true
                owner:EmitSound(domain_expansion_sound, 100)
                owner:Freeze(true)
                self:DomainExpansionBarrier()
                return 
            end
            else
            self:SetCursedEnergy(math.max(0, self:GetCursedEnergy() - 1000))
            timer.Create ("DomainAnimationFix"..self.SteamIDForTimer,0,1, function()
                self:SetHoldType("sukunaanims")
                owner:SetAnimation(PLAYER_RELOAD)
            end)
            if SERVER then
                for k, v in pairs( ents.GetAll()) do
                    if v:IsPlayer() then
                        net.Start( "sukunatimerreset" )
                        net.Send(v) 
                    end
                end
                local domain_expansion_sound = Sound("gjujutsu_kaisen/sukuna/domain_expansion_sound2.wav")
                self.domainActive = true
                owner:EmitSound(domain_expansion_sound, 100)
                owner:Freeze(true)
                self:DomainExpansion()
                return 
            end
        end
    end
end
function SWEP:DomainExpansionBarrier()
    local domain_expansion_sound = Sound("gjujutsu_kaisen/sukuna/domain_expansion_sound2.wav")
    self.infcdpassivedmg = CurTime() + 12
    self.infcdpassivedmg2 = CurTime() + 4.5

	local owner = self:GetOwner()
	local aimAngles = owner:GetAimVector():Angle()

    timer.Create ("DomainExpansionSukuna"..self.SteamIDForTimer,1.75,1, function()
		if not self:IsValid() then return end
		if not owner:IsValid() then return end

        if SERVER then
            net.Start( "effectsukuna1" )
            net.Broadcast()
            local radius = 15
            local pos = owner:GetPos()
            self.shlushkabablkwas2 = {}

			local domain = ents.Create("sukuna_domain_barrier")
			self:SetDomainExpansion(domain)
			domain:SetDomainOwner(owner)
            domain:SetPos(owner:GetPos() + aimAngles:Forward() * -265)
            domain:SetAngles(aimAngles)
            domain:Spawn()
            domain:Activate()

			timer.Simple(12, function()
				if not owner:IsValid() then return end

				owner:SetAnimation(PLAYER_ATTACK1)
				owner:Freeze(false)
				owner:GodDisable()
            end)
        end
    end)
end
function SWEP:DomainExpansion()
    local domain_expansion_sound = Sound("gjujutsu_kaisen/sukuna/domain_expansion_sound2.wav")
    self.infcdpassivedmg = CurTime() + 12
    self.infcdpassivedmg2 = CurTime() + 4.5

	local owner = self:GetOwner()
	local aimAngles = owner:GetAimVector():Angle()

    timer.Create ("DomainExpansionSukuna"..self.SteamIDForTimer,1.75,1, function()
		if not self:IsValid() then return end
		if not owner:IsValid() then return end

        if SERVER then
            net.Start( "effectsukuna1" )
            net.Broadcast()
            local radius = 15
            local pos = owner:GetPos()
            self.shlushkabablkwas2 = {}

			local domain = ents.Create("sukuna_domain")
			self:SetDomainExpansion(domain)
			domain:SetDomainOwner(owner)
            domain:SetPos(owner:GetPos() + aimAngles:Forward() * -265)
            domain:SetAngles(aimAngles)
            domain:Spawn()
            domain:Activate()

			timer.Simple(12, function()
				if not owner:IsValid() then return end

				owner:SetAnimation(PLAYER_ATTACK1)
				owner:Freeze(false)
				owner:GodDisable()
            end)
        end
    end)
end
timengforparticle = 0
timengforparticle2 = 0
if SERVER then
    util.AddNetworkString("sukunatimerreset")
end
if CLIENT then
	net.Receive("sukunatimerreset", function()
        timengforparticle = CurTime() + 12.25
        timengforparticle2 = CurTime() + 11.25
    end)
end
function SWEP:ReversedCursedTechnic()
    if IsValid(self) then
        self.Delay5 = self.Delay5 or CurTime()
        if CurTime() > self.Delay5 then
            self.Delay5 = CurTime() + 1
            if self.ReversCursedTechnic == true then
                self.ReversCursedTechnic = false
                else
                self.ReversCursedTechnic = true
            end
        end
    end
end

if SERVER then
    util.AddNetworkString("effectsukuna")
    util.AddNetworkString("removecamerasukuna")
end

if CLIENT then
    net.Receive("removecamerasukuna", function()
        local playerbase = net.ReadEntity()
        hook.Remove("CalcMainActivity", "SUKUNA_StopPlayerAnims" .. playerbase:SteamID())
        hook.Remove("DrawOverlay", "SUKUNA_CinematicBars" .. playerbase:SteamID())
        hook.Remove("HUDShouldDraw", "SUKUNA_NoHudCinematic" .. playerbase:SteamID())
        playerbase.camera:Stop()
        playerbase.copyjjk:Remove()
        playerbase:SetNoDraw(false)
    end)
	net.Receive("effectsukuna", function()
        owner = net.ReadEntity()
        SUKUNA_DomainExpansionCinematic(owner)
    end)
end
------------------------------------------
local maxFrames1 = 118
local fps1 = 24
local animRate1 = 1 / fps1
local interval1 = CurTime() + animRate1
local currentFrame1 = 0
if SERVER then
    util.AddNetworkString("effectsukuna1")
end
local ourMat1 = Material("models/limitless/matsdomainsukuna")
if CLIENT then
	net.Receive("effectsukuna1", function()
        currentFrame1 = 0
        hook.Add( "RenderScreenspaceEffects", "SukunaDomainEffect1", function()
            render.SetMaterial( ourMat1 )
            if CurTime() > interval1 then
                interval1 = CurTime() + animRate1
                currentFrame1 = currentFrame1 + 1
                
                if currentFrame1 > maxFrames1 then
                    hook.Remove("RenderScreenspaceEffects", "SukunaDomainEffect1")
                end
                ourMat1:SetInt("$frame", currentFrame1)
            end
            render.DrawScreenQuad(false)
        end)
    end)
end
function SWEP:DoPunch()
    if SERVER then
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        owner:LagCompensation(true)
        local animations = {'knife','melee','fist'}
        self:SetHoldType(animations[math.random(#animations)])
        local trace = util.TraceLine({
            start = owner:GetShootPos(),
            endpos = owner:GetShootPos() + (owner:GetAimVector() * 200),
            filter = owner
        })
        self.Owner:SetAnimation(PLAYER_ATTACK1)
        self.Owner:EmitSound(Sound("gjujutsu_kaisen/sfx/general/swings/swing_0"..math.random(1,4)..".mp3"))
        timer.Simple(0.2, function()
            if trace.Hit then
                if SERVER and trace.Entity != nil and IsValid(trace.Entity) and trace.Entity:IsSolid() and trace.Entity:Health() > 0 then
                    trace.Entity:TakeDamage(math.random(25,50), owner, self)
                    trace.Entity:EmitSound(Sound("gjujutsu_kaisen/sfx/general/punchs/punch_0"..math.random(1,5)..".mp3"))
                end
            end
        end)
        owner:LagCompensation(false)
        timer.Simple(0.3, function()
            if self != nil and IsValid(self) then
                self:SetHoldType("sukunaanims")
            end
        end)
    end
end
function SWEP:PrimaryAttack()  
    self:DoPunch()
    self:SetNextPrimaryFire(CurTime() + 0.32 ) 
end


function SWEP:SecondaryAttack()
    if CLIENT then return end
    local penis0 = self.Owner:GetAngles()
    penis0.p = 0
    penis0.r = 0
    local penis = penis0:Forward()

    --local penis1 = penis0:Right()
    local pos1 = self.Owner:WorldSpaceCenter() + penis * 100 --+ Vector(0,0,30) --+ penis1 * 40
    local endpos1 = self.Owner: WorldSpaceCenter() + penis * 220 --+ Vector(0,0,50) --+ penis1 * 60
    local mins1, maxs1 = Vector(-150,-35,-35), Vector(150,35,35)
    local tr1 = util.TraceHull( {
        start = pos1,
        endpos = endpos1,
        filter = {self.Owner},
        mins = mins1, 
        maxs = maxs1,
        mask = MASK_SHOT_HULL,
        collisiongroup =  COLLISION_GROUP_NONE
    } )
    if tr1.Hit then
        if IsValid(tr1.Entity) then
            SukunaPropCut(self.Owner, tr1.Entity, 0)
        end
    end
end

function SWEP:Slashes()
    self.SlashsDelay = self.SlashsDelay or CurTime()
    if self:GetCursedEnergy() >= 500 and CurTime() > self:GetSlashsDelay() then
        self:SetSlashsDelay(CurTime() + 30)
        for k, v in pairs( ents.FindInSphere(self.Owner:GetPos(), 1000) ) do
            if IsValid(v) and v ~= self.Owner and v:IsPlayer() or v:IsNPC() or v:IsNextBot() then
                if SERVER then
                    v.slashed = ents.Create("ent_sukuna_slashs")
                    v.slashed:SetOwner(self.Owner)
                    v.slashed:Spawn()
                    self.Owner:EmitSound(Sound("gjujutsu_kaisen/sfx/sukuna/voice/gambare.wav"))
                    timer.Create("setslashespos"..v:GetName(), 0, 0, function()
                        if IsValid(v) and IsValid(v.slashed) then
                            v.slashed:SetPos(v:GetPos() + v:GetUp() * 50)
                        end
                    end)
                end
            end
        end
    end
end

function SWEP:Dismantle()
    self.SlashsDelay2 = self.SlashsDelay2 or CurTime()
    if self:GetCursedEnergy() >= 500 and CurTime() > self:GetSlashsDelay2() then
        self:SetSlashsDelay2(CurTime() + 1)
        timer.Create ("ArrowAnimationFix"..self.SteamIDForTimer,0,1, function()
            self:SetHoldType("sukunaanims3")
            self.Owner:SetAnimation(PLAYER_RELOAD)
        end)
        timer.Simple(1, function()
            if IsValid(self) then
                if SERVER then
                    self.slashed2 = ents.Create("ent_sukuna_dismantel")
                    self.slashed2:SetOwner(self.Owner)
                    self.slashed2:Spawn()
                end
            end
        end)
    end
end


function SWEP:MahoragaWheelActive()
    self.Delay2 = self.Delay2 or CurTime()
    if CurTime() > self.Delay2 then
        self.Delay2 = CurTime() + 2
        self.mahoragawheel = !self.mahoragawheel
        if SERVER and self.mahoragawheel == false then
            local adaptation = self.Owner:GetNetVar("Adaptation")
            if (adaptation == nil) then return end
            for k, v in pairs(adaptation) do
                if v[1] == self.Owner then
                    self.Owner:SetNWBool("AdaptationPokaz_"..v[2]:GetName(), false)
                    timer.Destroy("addAdaptationProcent_"..self.Owner:GetName().."_"..v[2]:GetName())
                    self.Owner:SetNWInt("AdaptationProcent_"..v[2]:GetName(), 0)
                    self.Owner:SetNWInt("AdaptationProcentDouble_"..v[2]:GetName(), 1)
                    self.Owner:SetNWBool("AdaptationPlayer_"..v[2]:GetName(), false)
                    v[2]:SetNWBool("AdaptationPlayer_"..self.Owner:GetName(), false)
                    self.Owner:SetNetVar("Adaptation", {})
                    v[2]:SetNetVar("Adaptation", {})
                end
            end
        end
    end
end

function SWEP:FireArrow()
    self.Delay3 = self.Delay3 or CurTime()
    if CurTime() > self.Delay3 and self.Owner:OnGround() then
        self.Delay3 = CurTime() + 1
        self.Owner:AddFlags(FL_ATCONTROLS)
        timer.Create ("ArrowAnimationFix"..self.SteamIDForTimer,0,1, function()
            self:SetHoldType("sukunaanims2")
            self.Owner:SetAnimation(PLAYER_RELOAD)
        end)
        timer.Simple(0.7, function()
            if IsValid(self) then
                self.drawarrow = true
            end
        end)
        timer.Simple(1.3, function()
            if IsValid(self) then
                self.drawarrow = false
                if SERVER then
                    self.firearrow = ents.Create("ent_sukuna_fire_arrow")
                    self.firearrow:SetOwner(self.Owner)
                    self.firearrow:SetAngles(self.Owner:GetAngles())
                    self.firearrow:Spawn()
                end
            end
        end)
        timer.Simple(0.7, function()
            if SERVER then
                self.Owner:EmitSound(Sound("gjujutsu_kaisen/sfx/sukuna/voice/know_ur_place.wav"))
            end
        end)
        timer.Simple(3, function()
            if IsValid(self) and IsValid(self.Owner) then
                self.Owner:RemoveFlags(FL_ATCONTROLS)
            end
        end)
    end
    /*if SERVER then
        local bone1 = "ValveBiped.Bip01_L_Finger22"
        local bone2 = "ValveBiped.Bip01_R_Finger12"
        self.TrailEffect = util.SpriteTrail( self.Owner, 0, Color(255,0,0), true, 1, 1, 2, 1 / ( 15 + 1 ) * 0.5, "trails/plasma" )
        timer.Simple(0.8, function()
            if IsValid(self) and self.TrailEffect != nil and self.TrailEffect:IsValid() then
                self.TrailEffect:Remove()
            end
        end)
    end*/
end

function SWEP:Think()
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    if self.Owner != nil and IsValid(self.Owner) then
        self.SteamIDForTimer = self.Owner:SteamID64()
        if SERVER then
            self.Owner:SetMaxHealth(3000)
        end
    end
    ply:SetGravity(0.60)
    if self.Owner:KeyDown(IN_SPEED) then
        self.Owner:SetWalkSpeed(450)
        self.Owner:SetRunSpeed(850)
        self.Owner:SetJumpPower(300)
        else
        self.Owner:SetWalkSpeed(350)
        self.Owner:SetRunSpeed(650)
        self.Owner:SetJumpPower(250)
    end
    self.reversedenergy = self.reversedenergy or CurTime()
    if self.reversedenergy < CurTime() and self:GetMindHealth() >= 10 then
        self.reversedenergy = CurTime() + 0.5
        self:SetCursedEnergy(math.min(2500, self:GetCursedEnergy() + 5))
        self:SetMindHealth(math.min(100, self:GetMindHealth() + 1))
    end
    self.rctcd = self.rctcd or CurTime()
    if self.rctcd < CurTime() and self:GetMindHealth() >= 10 and self.ReversCursedTechnic == true then
        self.rctcd = CurTime() + 1
        local currentHealth = ply:Health()
        local maxHealth = 3000
        if currentHealth == maxHealth then return end
        ply:SetHealth(math.min(currentHealth + 50, maxHealth))
        self:SetMindHealth(math.min(100, self:GetMindHealth() - 5))
    end
    local penis0 = self.Owner:GetAngles()
    penis0.p = 0
    penis0.r = 0
    local penis1 = penis0:Forward()
    local penis2 = penis0:Up()
    if SERVER and self.mahoragawheel == true then
        if !IsValid(self.mahoragawheelprop) then
            self:SetMahoragaWheel( ents.Create( "ent_mahoraga_wheel" ))
            self.mahoragawheelprop = self:GetMahoragaWheel()
            if IsValid(self.mahoragawheelprop) then
                self.mahoragawheelprop:SetPos( self.Owner:WorldSpaceCenter() + penis1 * 5 + penis2 * 40)
                self.mahoragawheelprop:SetOwner(self.Owner)
                self.mahoragawheelprop:Spawn()
            end
        end
        elseif SERVER and self.mahoragawheel == false then
        if IsValid(self.mahoragawheelprop) then
            self.mahoragawheelprop:Remove()
        end
    end
    self.indcustedminuscd = self.indcustedminuscd or CurTime()
    if self.indcustedminuscd < CurTime() then
        self.indcustedminuscd = CurTime() + 0.5
        self:SetCursedEnergy(math.min(2500, self:GetCursedEnergy() + 2))
    end

	if CurTime() > self:GetNextEvent() and self:GetNextEvent() ~= 0 then
        local event = self:GetEvent()
        self:SetNextEvent(0)
        self[event](self)

		if SERVER then
			local players = {}

			for _, currentPly in player.Pairs() do
				if currentPly == ply then continue end
				table.insert(players, currentPly)
			end

			-- Send to all players except the local one as he already played the function
			net.Start("gJujutsu_cl_runEventFunction")
			gebLib_net.WriteEntity(self)
			net.WriteString(event)
			net.Send(players)
		end
    end
end

function SWEP:OnDrop()
    if IsValid(self.Owner) then
        self.Owner:Freeze(false)
        self.Owner:RemoveFlags(FL_ATCONTROLS)
    end
    if IsValid(self.mahoragawheelprop) then
        self.mahoragawheelprop:Remove()
    end
    if self.Owner != nil and IsValid(self.Owner) and self.domainActive then
        self.Owner:StopSound(Sound("gjujutsu_kaisen/sukuna/domain_expansion_sound2.wav"))
        timer.Remove("DomainExpansionSukuna"..self.SteamIDForTimer)
        self.Owner:Freeze(false)
        self.Owner:GodDisable()
        hook.Remove( "CalcView", "SukunaDomainExpansionCameraAnimation")
        for k, v in pairs( player.GetAll() ) do
            if self.shlushkabablkwas2 and self.shlushkabablkwas2[v] then
                v:SetNWBool("indomainsukuna", false)
                self.shlushkabablkwas2[v] = false
            end
        end
    end
    if SERVER then
        local adaptation = self.Owner:GetNetVar("Adaptation")
        if (adaptation == nil) then return end
        for k, v in pairs(adaptation) do
            if v[1] == self.Owner then
                self.Owner:SetNWBool("AdaptationPokaz_"..v[2]:GetName(), false)
                timer.Destroy("addAdaptationProcent_"..self.Owner:GetName().."_"..v[2]:GetName())
                self.Owner:SetNWInt("AdaptationProcent_"..v[2]:GetName(), 0)
                self.Owner:SetNWInt("AdaptationProcentDouble_"..v[2]:GetName(), 1)
                self.Owner:SetNWBool("AdaptationPlayer_"..v[2]:GetName(), false)
                v[2]:SetNWBool("AdaptationPlayer_"..self.Owner:GetName(), false)
                self.Owner:SetNetVar("Adaptation", {})
                v[2]:SetNetVar("Adaptation", {})
            end
        end
    end
end

function SWEP:OnRemove()
    if IsValid(self.Owner) then
        self.Owner:Freeze(false)
        self.Owner:RemoveFlags(FL_ATCONTROLS)
    end
    if IsValid(self.mahoragawheelprop) then
        self.mahoragawheelprop:Remove()
    end
    if self.Owner != nil and IsValid(self.Owner) and self.domainActive then
        self.Owner:StopSound(Sound("gjujutsu_kaisen/sukuna/domain_expansion_sound2.wav"))
        timer.Remove("DomainExpansionSukuna"..self.SteamIDForTimer)
        self.Owner:Freeze(false)
        self.Owner:GodDisable()
        hook.Remove( "CalcView", "SukunaDomainExpansionCameraAnimation")
        for k, v in pairs( player.GetAll() ) do
            if self.shlushkabablkwas2 and self.shlushkabablkwas2[v] then
                v:SetNWBool("indomainsukuna", false)
                self.shlushkabablkwas2[v] = false
            end
        end
    end
    if SERVER then
        local adaptation = self.Owner:GetNetVar("Adaptation")
        if (adaptation == nil) then return end
        for k, v in pairs(adaptation) do
            if v[1] == self.Owner then
                self.Owner:SetNWBool("AdaptationPokaz_"..v[2]:GetName(), false)
                timer.Destroy("addAdaptationProcent_"..self.Owner:GetName().."_"..v[2]:GetName())
                self.Owner:SetNWInt("AdaptationProcent_"..v[2]:GetName(), 0)
                self.Owner:SetNWInt("AdaptationProcentDouble_"..v[2]:GetName(), 1)
                self.Owner:SetNWBool("AdaptationPlayer_"..v[2]:GetName(), false)
                v[2]:SetNWBool("AdaptationPlayer_"..self.Owner:GetName(), false)
                self.Owner:SetNetVar("Adaptation", {})
                v[2]:SetNetVar("Adaptation", {})
            end
        end
    end
end

function SWEP:Holster()
    if IsValid(self.Owner) then
        self.Owner:Freeze(false)
        self.Owner:RemoveFlags(FL_ATCONTROLS)
    end
    if IsValid(self.mahoragawheelprop) then
        self.mahoragawheelprop:Remove()
    end
    if self.Owner != nil and IsValid(self.Owner) and self.domainActive then
        self.Owner:StopSound(Sound("gjujutsu_kaisen/sukuna/domain_expansion_sound2.wav"))
        timer.Remove("DomainExpansionSukuna"..self.SteamIDForTimer)
        self.Owner:Freeze(false)
        self.Owner:GodDisable()
        hook.Remove( "CalcView", "SukunaDomainExpansionCameraAnimation")
        for k, v in pairs( player.GetAll() ) do
            if self.shlushkabablkwas2 and self.shlushkabablkwas2[v] then
                v:SetNWBool("indomainsukuna", false)
                self.shlushkabablkwas2[v] = false
            end
        end
    end
    if SERVER then
        local adaptation = self.Owner:GetNetVar("Adaptation")
        if (adaptation == nil) then return end
        for k, v in pairs(adaptation) do
            if v[1] == self.Owner then
                self.Owner:SetNWBool("AdaptationPokaz_"..v[2]:GetName(), false)
                timer.Destroy("addAdaptationProcent_"..self.Owner:GetName().."_"..v[2]:GetName())
                self.Owner:SetNWInt("AdaptationProcent_"..v[2]:GetName(), 0)
                self.Owner:SetNWInt("AdaptationProcentDouble_"..v[2]:GetName(), 1)
                self.Owner:SetNWBool("AdaptationPlayer_"..v[2]:GetName(), false)
                v[2]:SetNWBool("AdaptationPlayer_"..self.Owner:GetName(), false)
                self.Owner:SetNetVar("Adaptation", {})
                v[2]:SetNetVar("Adaptation", {})
            end
        end
    end
	return true
end

function SWEP:DrawWorldModel()
    if self.drawarrow == true then
	    self:DrawModel() -- Draws Model Client Side
    end
end
