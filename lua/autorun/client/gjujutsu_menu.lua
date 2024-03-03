local ability3 = GetConVar("gjujutsu_ability3_key")
local ability4 = GetConVar("gjujutsu_ability4_key")
local ability5 = GetConVar("gjujutsu_ability5_key")
local ability6 = GetConVar("gjujutsu_ability6_key")
local ability7 = GetConVar("gjujutsu_ability7_key")
local ability8 = GetConVar("gjujutsu_ability8_key")
local abilityUltimate = GetConVar("gjujutsu_ultimate_key")
local abilityTaunt = GetConVar("gjujutsu_taunt_key")
local primary = GetConVar("gjujutsu_primary_key")
local secondary = GetConVar("gjujutsu_secondary_key")

local matOverlay_Normal = Material( "gui/gstands-contenticon-normal.png" )
local matOverlay_Hovered = Material( "gui/gstands-contenticon-hovered.png" )
local matOverlay_AdminOnly = Material( "icon16/shield.png" )

local convarMap = {
	["Ability 1"] = ability3,
	["Ability 2"] = ability4,
	["Ability 3"] = ability5,
	["Ability 4"] = ability6,
	["Ability 5"] = ability7,
	["Ability 6"] = ability8,
	["Ability Ultimate"] = abilityUltimate,
	["Primary"] = primary,
	["Secondary"] = secondary,
}

local white = color_white
local black = color_black
local blackNoOpacity = Color(0, 0, 0, 0)

local sweps = gJujutsu_Sweps

hook.Add("InitPostEntity", "gebLib_Missing", function()
	if gebLib then return end

	local frame = vgui.Create("DFrame")
	frame:SetSize(600, 160)
	frame:SetPos((ScrW() - frame:GetWide()) / 2, (ScrH() - frame:GetTall()) / 2)
	frame:SetTitle("Error: gebLib is missing")
	frame:SetBackgroundBlur(true)
	frame:MakePopup()

	local labelTitle = vgui.Create("DLabel", frame)
	labelTitle:SetPos(250, 35)
	labelTitle:SetText("gebLib is missing!")
	labelTitle:SetTextColor(Color(255,128,128))
	labelTitle:SizeToContents()
	
	local label1 = vgui.Create("DLabel", frame)
	label1:SetPos(10, 60)
	label1:SetText("You have an addon installed that requires gebLib but gebLib is missing. To install gebLib, click on the link below. Once\n                                                   installed, make sure it is enabled and then restart your game.")
	label1:SizeToContents()
	
	local link = vgui.Create("DLabelURL", frame)
	link:SetPos(195, 90)
	link:SetSize(300, 20)
	link:SetText("gebLib_Download_Link_(Steam_Workshop)")
	link:SetURL("https://steamcommunity.com/sharedfiles/filedetails/?id=3171164705")
	
	local buttonClose = vgui.Create("DButton", frame)
	buttonClose:SetText("CLOSE")
	buttonClose:SetPos(260, 120)
	buttonClose:SetSize(80, 35)
	buttonClose.DoClick = function()
		frame:Close()
	end
end)

spawnmenu.AddContentType("gJujutsu", function( container, obj)
	if not container:IsValid() then return end
	if !obj.material then return end
	if !obj.nicename then return end
	if !obj.spawnname then return end

	local textColor = white

	local icon = vgui.Create( "ContentIcon", container )
	icon:SetContentType( "gJujutsu" )
	icon:SetSpawnName( obj.spawnname )
	icon.Label:SetText( obj.nicename )
	icon.m_NiceName = obj.nicename 
	icon:SetMaterial( obj.material )
	icon:SetAdminOnly( obj.admin )
	icon:SetSize( 128, 128 )
	icon:SetTextColor(textColor)
	icon.Label:SetExpensiveShadow(0, blackNoOpacity)
	icon.Label:SetFont("Trebuchet18")

	icon.Paint = function( self, w, h )
		surface.SetDrawColor( textColor.r, textColor.g, textColor.b, 255 )
		if ( self.Depressed && !self.Dragging ) then
			if self.Border != 8 then
				self.Border = 8
				self:OnDepressionChanged( true )
			end
		else
			if self.Border != 0 then
				self.Border = 0
				self:OnDepressionChanged( false )
			end
		end
		render.PushFilterMag( TEXFILTER.ANISOTROPIC )
		render.PushFilterMin( TEXFILTER.ANISOTROPIC )
		self.Image:PaintAt( 3 + self.Border, 3 + self.Border, 128 - 8 - self.Border * 2, 128 - 8 - self.Border * 2 )
		render.PopFilterMin()
		render.PopFilterMag()
		if (!dragndrop.IsDragging() && ( self:IsHovered() or self.Depressed or self:IsChildHovered() )) then
			surface.SetMaterial( matOverlay_Hovered )
			self.Label:Hide()
		else
			surface.SetMaterial( matOverlay_Normal )
			self.Label:Show()
		end
		surface.SetDrawColor( textColor.r, textColor.g, textColor.b, 255 )
		surface.DrawTexturedRect( self.Border, self.Border, w-self.Border*2, h-self.Border*2 )
	end

	icon.DoClick = function()
		RunConsoleCommand( "gm_giveswep", obj.spawnname )
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	end

	container:Add(icon)

	return icon
end)

hook.Add( "PopulateGJujutsu", "AddgJujutsuContent", function( pnlContent, tree, node )
	local allWeapons = weapons.GetList()
	local gJujutsuSweps = {}

	-- Getting all the gJujutsu sweps
	for k, weapon in ipairs(allWeapons) do
		if weapon.Base ~= "gjujutsu_base" then continue end
		if not weapon.Spawnable then continue end

		table.insert(gJujutsuSweps, weapon)
	end

	-- Creating the gJujutsu weapons
	local node = tree:AddNode("Characters", "icon16/finger16.png" )
	node.DoPopulate = function( self )
		if self.PropPanel then return end

		self.PropPanel = vgui.Create("ContentContainer", self.PropPanel)
		self.PropPanel:SetVisible(false)
		self.PropPanel:SetTriggerSpawnlistChange(false)

		for _, swep in ipairs(gJujutsuSweps) do
			local pnl = spawnmenu.CreateContentIcon( swep.ScriptedEntityType or "gJujutsu", self.PropPanel, {
				nicename = swep.PrintName or swep.ClassName,
				spawnname = swep.ClassName,
				material = "entities/" .. swep.ClassName .. ".png",
				instructions = swep.Instructions,
				admin = swep.AdminSpawnable
			})

			pnl:SetTooltip(swep.Instructions)
		end
	end

	node.DoClick = function(self)
		self:DoPopulate()
		pnlContent:SwitchPanel(self.PropPanel)
	end

	node:InternalDoClick()
end)

spawnmenu.AddCreationTab("gJujutsu", function() 
	local ctrl = vgui.Create( "SpawnmenuContentPanel" )
	ctrl:EnableSearch("gJujutsuSweps", "PopulateGJujutsu")
	ctrl:CallPopulateHook( "PopulateGJujutsu" )
	return ctrl
end
,"icon16/finger16.png", 21, "gJujutsu")

function gJujutsuControlsTab(panel)
	panel:SetName("Controls")

	local AppList = vgui.Create( "DListView" )
	AppList:SetHeight(250)
	AppList:Dock(FILL)
	AppList:SetMultiSelect(false)
	AppList:AddColumn("Ability")
	AppList:AddColumn("Key")

	for abilityText, abilityConvar in pairs(convarMap) do
		AppList:AddLine(abilityText, input.GetKeyName(abilityConvar:GetInt()) )
	end

	function AppList:DoDoubleClick(lineID, line)
		input.StartKeyTrapping()
		self.Trapping = true
		self.selectedline = line
	end

	function AppList:Think()
		if input.IsKeyTrapping() and self.Trapping then
			local key =	input.CheckKeyTrapping()

			if key then
				if key != KEY_ESCAPE then
					local _, line = self:GetSelectedLine()
					local convar = convarMap[line:GetColumnText(1)]

					RunConsoleCommand(convar:GetName(), key)

					self.selectedline:SetColumnText(2, input.GetKeyName(key))
				end
				self.Trapping = false
			end
		end
	end

	panel:AddItem(AppList)
end

function gJujutsuPerfomanceTab(panel)
	panel:SetName("Performance")

	panel:CheckBox("Enable debris", "gjujutsu_fps_debris")
	panel:ControlHelp("Enables all debris and smoke created by abilities. HIGH FPS GAIN")
end

function gJujutsuGeneralTab(panel)
	if not LocalPlayer():IsAdmin() then return end
	
	panel:SetName("General")

	panel:NumSlider("Brain recover limit", "gjujutsu_misc_brain_recover_limit", 0, 1000, 0)
	panel:ControlHelp("How many times you can recover cooldowns until your brain gives up on you")
end

function gJujutsuDomainTab(panel)
	if not LocalPlayer():IsAdmin() then return end

	panel:SetName("Domains")

	panel:CheckBox("Enable domains", "gjujutsu_domain_enabled")
	panel:NumSlider("Domain max time", "gjujutsu_domain_max_time", 0, 1000)
	panel:ControlHelp("How long can you keep domain active until it clears on its own")
	panel:NumSlider("Domain end CD", "gjujutsu_domain_end_cd", 0, 1000)
	panel:ControlHelp("How big will be the cooldown on all abilities after domain ends")

	panel:CheckBox("Enable domain clashing", "gjujutsu_domain_clash_enabled")
	panel:NumSlider("Domain clash window", "gjujutsu_domai_clash_window", 1, 1000)
	panel:ControlHelp("How much time players have to join domain clash before it starts")
	panel:NumSlider("Domain clash length", "gjujutsu_domai_clash_length", 1, 1000)
	panel:ControlHelp("How long is the domain clash")
end

function gJujutsuGojoTab(panel)
	if not LocalPlayer():IsAdmin() then return end

	panel:SetName("Gojo Settings")

	panel:CheckBox("Unrestricted teleport", "gjujutsu_gojo_unrestricted_teleport")
	panel:ControlHelp("Enables teleporting with abilities like reversal red and hollow purple")
	panel:CheckBox("Infinity enabled", "gjujutsu_gojo_infinity_enabled")
	panel:CheckBox("Detonate hollow purple", "gjujutsu_gojo_detonate_purple")
	panel:ControlHelp("Will allow you to detonate hollow purple after firing one")
	panel:NumSlider("Six eyes damage mult", "gjujutsu_gojo_six_eyes_damage_mult", 1, 1000)
	panel:ControlHelp("Multiplies the damage of abilities when you have six eyes active")
end

function gJujutsuSukunaTab(panel)
	if not LocalPlayer():IsAdmin() then return end

	panel:SetName("Sukuna Settings")

	panel:NumSlider("Max fingers", "gjujutsu_sukuna_max_fingers", 1, 1000)

	panel:NumSlider("Fire arrow fingers", "gjujutsu_sukuna_fire_arrow_finger_req", 1, 1000, 0)
	panel:ControlHelp("How many fingers you need to have to use fire arrow")
	panel:CheckBox("Mahoraga wheel", "gjujutsu_sukuna_mahoraga_wheel")
	panel:ControlHelp("Enables the mahoraga wheel")
	panel:NumSlider("Wheel fingers", "gjujutsu_sukuna_mahoraga_wheel_finger_req", 1, 1000, 0)
	panel:ControlHelp("How many fingers you need to have to use mahoraga wheel")
	panel:NumSlider("Wheel dmg reduction", "gjujutsu_sukuna_mahoraga_wheel_damage_reduction", 1, 100)
	panel:ControlHelp("How much resistance you will have to attacks at max adaptation. Numbers are in percentages %")
	panel:NumSlider("Wheel adapt speed", "gjujutsu_sukuna_mahoraga_wheel_spin_time", 0.1, 1000)
	panel:ControlHelp("How fast you will adapt to phenomena")
end

function gJujutsuMenu()
	spawnmenu.AddToolMenuOption("Options", "gJujutsu", "gJujutsuControls", "Binds", "", "", gJujutsuControlsTab)
	spawnmenu.AddToolMenuOption("Options", "gJujutsu", "gJujutsuPerformance", "Performance", "", "", gJujutsuPerfomanceTab)

	spawnmenu.AddToolMenuOption("Options", "gJujutsu", "gJujutsuGeneral", "General", "", "", gJujutsuGeneralTab)
	spawnmenu.AddToolMenuOption("Options", "gJujutsu", "gJujutsuDomain", "Domain", "", "", gJujutsuDomainTab)
	spawnmenu.AddToolMenuOption("Options", "gJujutsu", "gJujutsuGojo", "Gojo", "", "", gJujutsuGojoTab)
	spawnmenu.AddToolMenuOption("Options", "gJujutsu", "gJujutsuSukuna", "Sukuna", "", "", gJujutsuSukunaTab)
end

hook.Add("PopulateToolMenu", "gJujutsuMenu", gJujutsuMenu)
