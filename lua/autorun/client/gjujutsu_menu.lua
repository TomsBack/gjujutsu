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

local white = color_white
local black = color_black
local blackNoOpacity = Color(0, 0, 0, 0)

local sweps = gJujutsu_Sweps

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

function gJujutsuControls(panel)
	panel:SetName( "Controls" )
	local AppList = vgui.Create( "DListView" )
	AppList:SetHeight(250)
	AppList:Dock( FILL )
	AppList:SetMultiSelect( false )

	local vars = {
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
	AppList:AddColumn("Ability")
	AppList:AddColumn("Key")
	AppList:AddLine("Ability 1", input.GetKeyName(ability3:GetInt()) )
	AppList:AddLine("Ability 2", input.GetKeyName(ability4:GetInt()) )
	AppList:AddLine("Ability 3", input.GetKeyName(ability5:GetInt()) )
	AppList:AddLine("Ability 4", input.GetKeyName(ability6:GetInt()) )
	AppList:AddLine("Ability 5", input.GetKeyName(ability7:GetInt()) )
	AppList:AddLine("Ability 6", input.GetKeyName(ability8:GetInt()) )
	AppList:AddLine("Ability Ultimate", input.GetKeyName(abilityUltimate:GetInt()) )
	AppList:AddLine("Primary", input.GetKeyName(primary:GetInt()) )
	AppList:AddLine("Secondary", input.GetKeyName(secondary:GetInt()) )
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
				LocalPlayer():ConCommand(vars[line:GetColumnText(1)]:GetName().." "..tostring(key))
				self.selectedline:SetColumnText(2, input.GetKeyName(key))
				LocalPlayer().gJujutsuControlsTable = {
					["ability3"] = ability3:GetInt(),
					["ability4"] = ability4:GetInt(),
					["ability5"] = ability5:GetInt(),
					["ability6"] = ability6:GetInt(),
					["ability7"] = ability7:GetInt(),
					["ability8"] = ability8:GetInt(),
					["abilityUltimate"] = abilityUltimate:GetInt(),
					["primary"] = primary:GetInt(),
					["secondary"] = secondary:GetInt(),
				}
			end
			self.Trapping = false
			end
		end
	end
	panel:AddItem(AppList)
end

function gJujutsuMenu()
	spawnmenu.AddToolMenuOption("Options", "gJujutsu", "gJujutsuControls", "Binds", "", "", gJujutsuControls)
end

hook.Add("PopulateToolMenu", "gJujutsuMenu", gJujutsuMenu)
