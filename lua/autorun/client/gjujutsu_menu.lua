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

spawnmenu.AddContentType( "gJujutsu", function( container, obj )
	if ( !obj.material ) then return end
	if ( !obj.nicename ) then return end
	if ( !obj.spawnname ) then return end
	local icon = vgui.Create( "ContentIcon", container )
	icon:SetContentType( "gJujutsu" )
	icon:SetSpawnName( obj.spawnname )
	icon.Label:SetText( obj.nicename )
	icon.m_NiceName = obj.nicename 
	icon:SetMaterial( obj.material )
	icon:SetAdminOnly( obj.admin )
	icon:SetSize( 128, 128 )
	local clr = Color( 255, 255, 255, 255 )
	icon:SetTextColor( clr )
	icon.Label:SetExpensiveShadow(0,Color(0,0,0,0))
	icon.Label:SetFont("Trebuchet18")
	icon.Paint = function( self, w, h )
		surface.SetDrawColor( clr.r, clr.g, clr.b, 255 )
		if ( self.Depressed && !self.Dragging ) then
			if ( self.Border != 8 ) then
				self.Border = 8
				self:OnDepressionChanged( true )
			end
			else
			if ( self.Border != 0 ) then
				self.Border = 0
				self:OnDepressionChanged( false )
			end
		end
		render.PushFilterMag( TEXFILTER.ANISOTROPIC )
		render.PushFilterMin( TEXFILTER.ANISOTROPIC )
		self.Image:PaintAt( 3 + self.Border, 3 + self.Border, 128 - 8 - self.Border * 2, 128 - 8 - self.Border * 2 )
		render.PopFilterMin()
		render.PopFilterMag()
		if ( !dragndrop.IsDragging() && ( self:IsHovered() || self.Depressed || self:IsChildHovered() ) ) then
			surface.SetMaterial( matOverlay_Hovered )
			self.Label:Hide()
			else
			surface.SetMaterial( matOverlay_Normal )
			self.Label:Show()
		end
		surface.SetDrawColor( clr.r, clr.g, clr.b, 255 )
		surface.DrawTexturedRect( self.Border, self.Border, w-self.Border*2, h-self.Border*2 )
	end
	icon.DoClick = function()
		RunConsoleCommand( "gm_giveswep", obj.spawnname )
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	end
	icon.DoMiddleClick = function()
		RunConsoleCommand( "gm_spawnswep", obj.spawnname )
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	end
	icon.OpenMenu = function( icon )
	end
	if ( IsValid( container ) ) then
		container:Add( icon )
	end
	return icon
end )
hook.Add( "PopulategJujutsu", "AddgJujutsuContent", function( pnlContent, tree, node )
	local Weapons = weapons.GetList()
	local Categorised = {}
	for k, weapon in pairs( Weapons ) do
		if ( !string.StartWith( weapon.ClassName, "gjujutsu_" ) or (weapon.AdminSpawnable)) or not weapon.Spawnable then continue end
		weapon.SubCategory = weapon.SubCategory or "gJujutsu"
		Categorised[ weapon.SubCategory ] = Categorised[ weapon.SubCategory ] or {}
		table.insert( Categorised[ weapon.SubCategory ], weapon )
	end
	Weapons = nil
	for CategoryName, v in SortedPairs( Categorised ) do
		local node = tree:AddNode( CategoryName, "icon16/gjujutsu_icon16.png" )
		node.DoPopulate = function( self )
			if ( self.PropPanel ) then return end
			self.PropPanel = vgui.Create( "ContentContainer", self.PropPanel )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )
			for k, ent in SortedPairsByMemberValue( v, "PrintName" ) do
				local pnl = spawnmenu.CreateContentIcon( ent.ScriptedEntityType or "gJujutsu", self.PropPanel, {
					nicename	= ent.PrintName or ent.ClassName,
					spawnname	= ent.ClassName,
					material	= "entities/" .. ent.ClassName .. ".png",
					standmodel	= ent.StandModel,
					instructions	= ent.Instructions,
					admin		= ent.AdminSpawnable
				} )
				pnl:SetTooltip(ent.Instructions)
			end
		end
		node.DoClick = function( self )
			self:DoPopulate()
			pnlContent:SwitchPanel( self.PropPanel )
		end
	end
	local FirstNode = tree:Root():GetChildNode( 0 )
	if ( IsValid( FirstNode ) ) then
		FirstNode:InternalDoClick()
	end
end )
spawnmenu.AddCreationTab("gJujutsu", function() 
	local ctrl = vgui.Create( "SpawnmenuContentPanel" )
	ctrl:EnableSearch( "stands", "PopulategJujutsu" )
	ctrl:CallPopulateHook( "PopulategJujutsu" )
	return ctrl
end
,"icon16/gjujutsu_icon16.png", 21, "gJujutsu")
function gJujutsuControls(panel)
	panel:SetName( "Controls" )
	local AppList = vgui.Create( "DListView" )
	AppList:SetHeight(250)
	AppList:Dock( FILL )
	AppList:SetMultiSelect( false )

	local vars = {
		["Способность 1"] = ability3,
		["Способность 2"] = ability4,
		["Спец.способность 2"] = ability5,
		["Спец.способность 1"] = ability6,
		["Обратная проклятая техника"] = ability7,
		["Ульт.способность 1"] = ability8,
		["Ульт.способность 2"] = abilityUltimate,
		["Основное"] = primary,
		["Дополнительное"] = secondary,
	}
	AppList:AddColumn("Ability")
	AppList:AddColumn("Key")
	AppList:AddLine( "Способность 1", input.GetKeyName(ability3:GetInt()) )
	AppList:AddLine( "Способность 2", input.GetKeyName(ability4:GetInt()) )
	AppList:AddLine( "Спец.способность 1", input.GetKeyName(ability5:GetInt()) )
	AppList:AddLine( "Спец.способность 2", input.GetKeyName(ability6:GetInt()) )
	AppList:AddLine( "Обратная проклятая техника", input.GetKeyName(ability7:GetInt()) )
	AppList:AddLine( "Ульт.способность 1", input.GetKeyName(ability8:GetInt()) )
	AppList:AddLine( "Ульт.способность 2", input.GetKeyName(abilityUltimate:GetInt()) )
	AppList:AddLine( "Основное", input.GetKeyName(primary:GetInt()) )
	AppList:AddLine( "Дополнительное", input.GetKeyName(secondary:GetInt()) )
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
