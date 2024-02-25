CreateClientConVar( "gjujutsu_thirdperson_offset", "0,0,5", true, false, "#gjujutsu.offset" )
CreateConVar( "gjujutsu_show_hitboxes", 0, {FCVAR_NONE, FCVAR_CHEAT}, "#gjujutsu.hitboxes" ) 

CreateClientConVar("gjujutsu_fps_debris", 1, true, false, "If enabled, then debris is going to spawn", 0, 1)

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
CreateClientConVar("gjujutsu_block_key", 16, true, true, "Sets the block key", BUTTON_CODE_NONE, BUTTON_CODE_LAST)

-- Misc convars
CreateConVar("gjujutsu_misc_brain_recover_limit", 5, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Maximum amounts of time you can recover your brain. 0 For disabling", 0, 1000)

-- Gojo convars
CreateConVar("gjujutsu_gojo_unrestricted_teleport", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Allows gojo to teleport while holding other cursed techniques", 0, 1)
CreateConVar("gjujutsu_gojo_detonate_purple", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Allows gojo to detonate hollow purple when you press the button again", 0, 1)

-- Sukuna convars
CreateConVar("gjujutsu_sukuna_max_fingers", 20, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Defines how much fingers sukuna can have", 1, 1000)
CreateConVar("gjujutsu_sukuna_mahoraga_wheel", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Allows Sukuna to use Mahoraga's wheel", 0, 1)
