game.AddParticles("particles/gojo_particles.pcf")
game.AddParticles("particles/purple_explosion.pcf")
game.AddParticles("particles/purple_clash_explosion.pcf")
game.AddParticles("particles/hollow_purple/purple_fragments.pcf")
game.AddParticles("particles/hollow_purple/blue_red_combine.pcf")
game.AddParticles( "particles/gjujutsu_fx.pcf" )	
game.AddParticles("particles/gojo_particles.pcf")
game.AddParticles("particles/purple_explosion.pcf")
game.AddParticles("particles/purple_fragments.pcf")
game.AddParticles("particles/blue_red_combine.pcf")
game.AddParticles("particles/red.pcf")
game.AddParticles("particles/smoke_general.pcf")
game.AddParticles("particles/infinite_void.pcf")
game.AddParticles("particles/hollow_purple.pcf")
game.AddParticles("particles/reverse_cursed.pcf")
game.AddParticles("particles/fire_arrow.pcf")

------------------------------------------------------------------------------

PrecacheParticleSystem("BlueOrb") // Синяя сфера, разбивается вместе со стеклом
	PrecacheParticleSystem("BlueOrb_Dust")
	PrecacheParticleSystem("BlueOrb_Flare")
	PrecacheParticleSystem("BlueOrb_FlareExplode")
	PrecacheParticleSystem("BlueOrb_Shards")
	PrecacheParticleSystem("BlueOrb_ShardsExplode")	// Стекло по отдельности
	
PrecacheParticleSystem("BlueOrb_NoShards")	// Взрыв без стекла

PrecacheParticleSystem("BlueOrb_Huge") // Огромный размер
	PrecacheParticleSystem("BlueOrb_Huge_Dust")
	PrecacheParticleSystem("BlueOrb_Huge_Flare")
	PrecacheParticleSystem("BlueOrb_Huge_FlareExplode")
	PrecacheParticleSystem("BlueOrb_Huge_Shards")
	PrecacheParticleSystem("BlueOrb_Huge_ShardsExplode")
	
------------------------------------------------------------------------------НОВОЕ

PrecacheParticleSystem("BlueBall") // Синий шар для HollowPurple с оффсетом и молнией
PrecacheParticleSystem("BlueBall_Center") // Синий шар для HollowPurple без оффсета, для молнии через .lua можно использовать текстуру "sprites\gjujutsu\beam_electrical_2_add.vmt"
	PrecacheParticleSystem("BlueBall_Smoke")
	PrecacheParticleSystem("BlueBall_BlackSmokeBits")
	PrecacheParticleSystem("BlueBall_Energy")
	PrecacheParticleSystem("BlueBall_Energy2")
	PrecacheParticleSystem("BlueBall_PullingBits")
	PrecacheParticleSystem("BlueBall_BlueSmokeBits")
	PrecacheParticleSystem("BlueBall_Circle")
	PrecacheParticleSystem("BlueBall_ElectroTrail")
	PrecacheParticleSystem("BlueBall_ElectroRoot")	
	PrecacheParticleSystem("BlueBall_Electricity")
	PrecacheParticleSystem("BlueBall_Connector")	
	
PrecacheParticleSystem("RedBall") // Красный шар для HollowPurple с оффсетом и молнией
PrecacheParticleSystem("RedBall_Center") // Красный шар для HollowPurple без оффсета, для молнии через .lua можно использовать текстуру "sprites\gjujutsu\beam_electrical_2_add.vmt"
	PrecacheParticleSystem("RedBall_Smoke")
	PrecacheParticleSystem("RedBall_BlackSmokeBits")
	PrecacheParticleSystem("RedBall_Energy")
	PrecacheParticleSystem("RedBall_Energy2")
	PrecacheParticleSystem("RedBall_PullingBits")
	PrecacheParticleSystem("RedBall_RedSmokeBits")
	PrecacheParticleSystem("RedBall_Circle")
	PrecacheParticleSystem("RedBall_ElectroTrail")
	PrecacheParticleSystem("RedBall_ElectroRoot")	
	PrecacheParticleSystem("RedBall_Electricity")
	PrecacheParticleSystem("RedBall_Connector")	
	
PrecacheParticleSystem("HollowPurple_Balls") // Единый статичный партикл из двух выше
	
------------------------------------------------------------------------------
	
PrecacheParticleSystem("Shrine_Large") // Порезы с большой зоной действия
	PrecacheParticleSystem("Shrine_CutsLarge")
	PrecacheParticleSystem("Shrine_DebrisLarge")
	
PrecacheParticleSystem("Shrine_Medium") // Порезы со средней зоной действия
	PrecacheParticleSystem("Shrine_CutsMedium")
	PrecacheParticleSystem("Shrine_DebrisMedium")	
	
PrecacheParticleSystem("Shrine_Small") // Порезы с малой зоной действия на 3 секунды
	PrecacheParticleSystem("Shrine_CutsSmall")	
	PrecacheParticleSystem("Shrine_CutsOMR") // Отдельно на модель
	PrecacheParticleSystem("Shrine_DebrisSmall")	
	
PrecacheParticleSystem("YLapse") // Синий ураган
	PrecacheParticleSystem("YLapse_Blue1")
	PrecacheParticleSystem("YLapse_Blue2")
	PrecacheParticleSystem("YLapse_Blue3")
	PrecacheParticleSystem("YLapse_Wind")

PrecacheParticleSystem("hollow_purple")
PrecacheParticleSystem("hollow_purple_explosion")

PrecacheParticleSystem("purple_fragment")

PrecacheParticleSystem("blue_red_combine")

PrecacheParticleSystem("hollow_purple")
PrecacheParticleSystem("hollow_purple_explosion")

PrecacheParticleSystem("purple_fragment")
PrecacheParticleSystem("blue_red_combine")

PrecacheParticleSystem("technique_red")
PrecacheParticleSystem("technique_red_explosion")

PrecacheParticleSystem("clash_explosion")

PrecacheParticleSystem("domain_splatters")

PrecacheParticleSystem("dismantle_slash")
PrecacheParticleSystem("cleave")

PrecacheParticleSystem("reverse_cursed")
