
CreateClientConVar( "gjujutsu_thirdperson_offset", "0,0,5", true, false, "#gjujutsu.offset" )
CreateConVar( "gjujutsu_show_hitboxes", 0, {FCVAR_NONE, FCVAR_CHEAT}, "#gjujutsu.hitboxes" ) 

CreateClientConVar("gjujutsu_debris", 1, true, false, "If enabled, then debris is going to sapwn the hollow purple is near obstacles.", 0, 1)

CreateClientConVar("gjujutsu_ability3_key", 28, true, true, "Sets the 3th ability key", BUTTON_CODE_NONE, BUTTON_CODE_LAST)
CreateClientConVar("gjujutsu_ability4_key", 15, true, true, "Sets the 4th ability key", BUTTON_CODE_NONE, BUTTON_CODE_LAST)
CreateClientConVar("gjujutsu_ability5_key", 12, true, true, "Sets the 5th ability key", BUTTON_CODE_NONE, BUTTON_CODE_LAST)
CreateClientConVar("gjujutsu_ability6_key", 18, true, true, "Sets the 6th ability key", BUTTON_CODE_NONE, BUTTON_CODE_LAST)
CreateClientConVar("gjujutsu_ability7_key", 17, true, true, "Sets the 7th ability key", BUTTON_CODE_NONE, BUTTON_CODE_LAST)
CreateClientConVar("gjujutsu_ability8_key", 20, true, true, "Sets the 8th ability key", BUTTON_CODE_NONE, BUTTON_CODE_LAST)
CreateClientConVar("gjujutsu_ultimate_key", 30, true, true, "Sets the ultimate ability key", BUTTON_CODE_NONE, BUTTON_CODE_LAST)
CreateClientConVar("gjujutsu_taunt_key", 50, true, true, "Sets the taunt ability key", BUTTON_CODE_NONE, BUTTON_CODE_LAST)
CreateClientConVar("gjujutsu_primary_key", 107, true, true, "Sets the primary ability key", BUTTON_CODE_NONE, BUTTON_CODE_LAST)
CreateClientConVar("gjujutsu_secondary_key", 108, true, true, "Sets the secondary ability key", BUTTON_CODE_NONE, BUTTON_CODE_LAST)

-- Gojo convars
CreateConVar("gjujutsu_gojo_unrestricted_teleport", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Allows gojo to teleport while holding other cursed techniques", 0, 1)
CreateConVar("gjujutsu_gojo_detonate_purple", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Allows gojo to detonate hollow purple when you press the button again", 0, 1)
