extends Node
class_name Remix_Music

onready var level = get_parent()
onready var music_player = level.get_node_or_null("Music Player")


onready var boss_intro_save = music_player.boss_intro
onready var boss_loop_save = music_player.boss_song
onready var angry_boss_intro_save = music_player.angry_boss_intro
onready var angry_boss_loop_save = music_player.angry_boss_song
onready var stage_intro_save = music_player.stage_intro
onready var stage_loop_save = music_player.stage_song
onready var miniboss_intro_save = music_player.miniboss_intro
onready var miniboss_loop_save = music_player.miniboss_song
onready var capsule_loop_save = music_player.capsule_song
onready var stage_clear_save = music_player.stage_clear_song

onready var _original_lumine_appears: AudioStream = preload("res://src/Sounds/OST - LumineAppears.ogg")
onready var _original_lumine_end: AudioStream = preload("res://src/Sounds/OST - LumineAppears - End.ogg")
onready var _original_vile_appears: AudioStream = preload("res://src/Sounds/OST - VileAppears.ogg")

onready var _original_lava_intro: AudioStream = preload("res://src/Sounds/OST - Inferno - LavaIntro.ogg")
onready var _original_lava_loop: AudioStream = preload("res://src/Sounds/OST - Inferno - LavaLoop.ogg")

onready var _original_alt_stage_intro: AudioStream = preload("res://src/Sounds/OST - Metal Valley 1 - Intro.ogg")
onready var _original_alt_stage_loop: AudioStream = preload("res://src/Sounds/OST - Metal Valley 1 - Loop.ogg")

onready var _original_pitchblack_alarm_intro: AudioStream = preload("res://src/Sounds/OST - PitchBlack - AlarmIntro.ogg")
onready var _original_pitchblack_alarm_loop: AudioStream = preload("res://src/Sounds/OST - PitchBlack - AlarmLoop.ogg")

onready var _original_gatewayescape_intro: AudioStream = preload("res://src/Sounds/OST - GatewayEscape - Intro.ogg")
onready var _original_gatewayescape_loop: AudioStream = preload("res://src/Sounds/OST - GatewayEscape - Loop.ogg")

onready var _original_sigma_demo_intro: AudioStream = preload("res://src/Sounds/OST - SigmaDemo.ogg")
onready var _original_sigma_demo_loop: AudioStream = preload("res://src/Sounds/OST - SigmaDemo - Loop.ogg")



onready var _maverickintro: AudioStream = preload("res://Remix/Songs/Stage Start.ogg")
onready var _weaponget: AudioStream = preload("res://Remix/Songs/Weapon Get.ogg")
onready var _stageclear: AudioStream = preload("res://Remix/Songs/Stage Clear.ogg")
onready var _titlescreen: AudioStream = preload("res://Remix/Songs/Title Screen.ogg")
onready var _capsule: AudioStream = preload("res://Remix/Songs/Capsule.ogg")
onready var _capsule_final: AudioStream = preload("res://Remix/Songs/Capsule Final.ogg")
onready var _sorrow_loop: AudioStream = preload("res://Remix/Songs/Sorrow.ogg")
onready var _problem: AudioStream = preload("res://Remix/Songs/Problem.mp3")
onready var _fate_to_fight: AudioStream = preload("res://Remix/Songs/Fate to Fight.ogg")#Not ready

onready var _boss_demo: AudioStream = preload("res://src/Sounds/OST - Boss Demo.ogg")
onready var _boss_demo_demake: AudioStream = preload("res://Remix/Songs/Boss Demo.ogg")


onready var _stage_over_intro: AudioStream = preload("res://Remix/Songs/Stage Over Intro.ogg")
onready var _stage_over_loop: AudioStream = preload("res://Remix/Songs/Stage Over Loop.ogg")
onready var _char_selection_intro: AudioStream = preload("res://Remix/Songs/Char Selection Intro.ogg")#Not ready
onready var _char_selection_loop: AudioStream = preload("res://Remix/Songs/Char Selection Loop.ogg")#Not ready


onready var _mid_boss_intro: AudioStream = preload("res://Remix/Songs/MiniBoss - Intro.ogg")
onready var _mid_boss_loop: AudioStream = preload("res://Remix/Songs/MiniBoss - Loop.ogg")
onready var _boss_intro: AudioStream = preload("res://Remix/Songs/Boss Battle - Intro.ogg")
onready var _boss_loop: AudioStream = preload("res://Remix/Songs/Boss Battle - Loop.ogg")
onready var _bossangry_intro: AudioStream = preload("res://Remix/Songs/Angry Boss Battle - Intro.ogg")
onready var _bossangry_loop: AudioStream = preload("res://Remix/Songs/Angry Boss Battle - Loop.ogg")


onready var _vile_intro: AudioStream = preload("res://Remix/Songs/Vile Battle - Intro.ogg")
onready var _vile_loop: AudioStream = preload("res://Remix/Songs/Vile Battle - Loop.ogg")


onready var _copysigma_intro: AudioStream = preload("res://Remix/Songs/Copy Sigma Battle - Intro.ogg")
onready var _copysigma_loop: AudioStream = preload("res://Remix/Songs/Copy Sigma Battle - Loop.ogg")


onready var _sigmax8_intro: AudioStream = preload("res://Remix/Songs/Sigma_X8_Fifght_Intro.ogg")
onready var _sigmax8_loop: AudioStream = preload("res://Remix/Songs/Sigma_X8_Fifght_Loop.ogg")


onready var _lumine1_loop: AudioStream = preload("res://Remix/Songs/Lumine Battle 1 - Loop.ogg")
onready var _lumine2_intro: AudioStream = preload("res://Remix/Songs/Lumine Battle 2 - Intro.ogg")
onready var _lumine2_loop: AudioStream = preload("res://Remix/Songs/Lumine Battle 2 - Loop.ogg")
onready var _paradiselost: AudioStream = preload("res://Remix/Songs/ParadiseLost.ogg")
onready var _original_paradiselost: AudioStream = preload("res://src/Sounds/OST - ParadiseLost.ogg")


onready var _noahspark_intro: AudioStream = preload("res://Remix/Songs/Noahs Park - Intro.ogg")
onready var _noahspark_loop: AudioStream = preload("res://Remix/Songs/Noahs Park - Loop.ogg")
onready var _intrusion_intro: AudioStream = preload("res://Remix/Songs/Intrusion - Intro.ogg")
onready var _intrusion_loop: AudioStream = preload("res://Remix/Songs/Intrusion - Loop.ogg")
onready var _lumine_appears: AudioStream = preload("res://Remix/Songs/LumineAppears.ogg")
onready var _lumine_end: AudioStream = preload("res://Remix/Songs/LumineAppears - End.ogg")
onready var _vile_appears: AudioStream = preload("res://Remix/Songs/VileAppears.ogg")

onready var _boosterforest_intro: AudioStream = preload("res://Remix/Songs/Booster Forest - Intro.ogg")
onready var _boosterforest_loop: AudioStream = preload("res://Remix/Songs/Booster Forest - Loop.ogg")
onready var _ridearmor_intro: AudioStream = preload("res://Remix/Songs/Ride Armor - Intro.ogg")
onready var _ridearmor_loop: AudioStream = preload("res://Remix/Songs/Ride Armor - Loop.ogg")


onready var _centralwhite_intro: AudioStream = preload("res://Remix/Songs/Central White - Intro.ogg")
onready var _centralwhite_loop: AudioStream = preload("res://Remix/Songs/Central White - Loop.ogg")


onready var _dynasty_intro: AudioStream = preload("res://Remix/Songs/Dynasty - Intro.ogg")
onready var _dynasty_loop: AudioStream = preload("res://Remix/Songs/Dynasty - Loop.ogg")


onready var _inferno_intro: AudioStream = preload("res://Remix/Songs/Inferno - Intro.ogg")
onready var _inferno_loop: AudioStream = preload("res://Remix/Songs/Inferno - Loop.ogg")
onready var _lava_intro: AudioStream = preload("res://Remix/Songs/Inferno - LavaIntro.ogg")
onready var _lava_loop: AudioStream = preload("res://Remix/Songs/Inferno - LavaLoop.ogg")


onready var _metalvalley_intro: AudioStream = preload("res://Remix/Songs/Metal Valley - Intro.ogg")
onready var _metalvalley_loop: AudioStream = preload("res://Remix/Songs/Metal Valley - Loop.ogg")
onready var _metalvalley2_intro: AudioStream = preload("res://Remix/Songs/Metal Valley 2 - Intro.ogg")
onready var _metalvalley2_loop: AudioStream = preload("res://Remix/Songs/Metal Valley 2 - Loop.ogg")


onready var _pitchblack_intro: AudioStream = preload("res://Remix/Songs/PitchBlack - Intro.ogg")
onready var _pitchblack_loop: AudioStream = preload("res://Remix/Songs/PitchBlack - Loop.ogg")
onready var _pitchblack_alarm_intro: AudioStream = preload("res://Remix/Songs/PitchBlack - AlarmIntro.ogg")
onready var _pitchblack_alarm_loop: AudioStream = preload("res://Remix/Songs/PitchBlack - AlarmLoop.ogg")


onready var _primrose_loop: AudioStream = preload("res://Remix/Songs/Primrose - Loop.ogg")


onready var _troiabase_intro: AudioStream = preload("res://Remix/Songs/Troia Base 1 - Intro.ogg")
onready var _troiabase_loop: AudioStream = preload("res://Remix/Songs/Troia Base 1 - Loop.ogg")
onready var _troiabase2_intro: AudioStream = preload("res://Remix/Songs/Troia Base 2 - Intro.ogg")
onready var _troiabase2_loop: AudioStream = preload("res://Remix/Songs/Troia Base 2 - Loop.ogg")


onready var _jakobelevator_intro: AudioStream = preload("res://Remix/Songs/Jakob - Intro.ogg")
onready var _jakobelevator_loop: AudioStream = preload("res://Remix/Songs/Jakob - Loop.ogg")


onready var _gateway_intro: AudioStream = preload("res://Remix/Songs/Gateway - Intro.ogg")
onready var _gateway_loop: AudioStream = preload("res://Remix/Songs/Gateway - Loop.ogg")
onready var _gatewayescape_intro: AudioStream = preload("res://Remix/Songs/GatewayEscape - Intro.ogg")#Not ready
onready var _gatewayescape_loop: AudioStream = preload("res://Remix/Songs/GatewayEscape - Loop.ogg")#Not ready


onready var _sigmapalace_intro: AudioStream = preload("res://Remix/Songs/Sigma Palace - Intro.ogg")
onready var _sigmapalace_loop: AudioStream = preload("res://Remix/Songs/Sigma Palace - Loop.ogg")
onready var _sigma_demo_intro: AudioStream = preload("res://Remix/Songs/SigmaDemo - Intro.ogg")
onready var _sigma_demo_loop: AudioStream = preload("res://Remix/Songs/SigmaDemo - Loop.ogg")

onready var _x_the_legend: AudioStream = preload("res://Remix/Songs/X, The Legend.ogg")

onready var _intro_demake: AudioStream = preload("res://Remix/Songs/RMEXE3 Showdown.ogg")
onready var _song_rmexe3_boss_intro: AudioStream = preload("res://Remix/Songs/RMEXE3 Boss Battle! Intro.ogg")
onready var _song_rmexe3_boss_loop: AudioStream = preload("res://Remix/Songs/RMEXE3 Boss Battle! Loop.ogg")
onready var _song_rmexe6_cybeasts_intro: AudioStream = preload("res://Remix/Songs/RMEXE6 Decisive Battle Cybeasts! Intro.ogg")
onready var _song_rmexe6_cybeasts_loop: AudioStream = preload("res://Remix/Songs/RMEXE6 Decisive Battle Cybeasts! Loop.ogg")


onready var _dj_sigma_intro: AudioStream = preload("res://Remix/Songs/Sigma_Fifght_Intro.ogg")#Not ready
onready var _dj_sigma_loop: AudioStream = preload("res://Remix/Songs/Sigma_Fifght_Loop.ogg")#Not ready
onready var _song_sigma_x7_intro: AudioStream = preload("res://Remix/Songs/Our Blood Boils (Sigma X7) Intro.ogg")
onready var _song_sigma_x7_loop: AudioStream = preload("res://Remix/Songs/Our Blood Boils (Sigma X7) Loop.ogg")
onready var _original_song_sigma_x7_intro: AudioStream = preload("res://src/Sounds/OST - Our Blood Boils (Sigma X7) Intro.ogg")
onready var _original_song_sigma_x7_loop: AudioStream = preload("res://src/Sounds/OST - Our Blood Boils (Sigma X7) Loop.ogg")


onready var _intro_red_demake: AudioStream = preload("res://Remix/Songs/Beginning_Theme_of_Red.ogg")#Not ready
onready var _original_intro_red: AudioStream = preload("res://src/Sounds/OST - Beginning_Theme_of_Red.ogg")
onready var _song_red_intro: AudioStream = preload("res://Remix/Songs/Relation_vs_Red_Intro.ogg")#Not ready
onready var _song_red_loop: AudioStream = preload("res://Remix/Songs/Relation_vs_Red_Loop.ogg")#Not ready
onready var _original_song_red_intro: AudioStream = preload("res://src/Sounds/OST - Relation_vs_Red_Intro.ogg")
onready var _original_song_red_loop: AudioStream = preload("res://src/Sounds/OST - Relation_vs_Red_Loop.ogg")


onready var z3_x_vs_zero_intro_enhanced: AudioStream = preload("res://Remix/Songs/X VS ZERO Z3 Remix Intro.ogg")
onready var z3_x_vs_zero_loop_enhanced: AudioStream = preload("res://Remix/Songs/X VS ZERO Z3 Remix Loop.ogg")
onready var z3_cannon_ball_intro: AudioStream = preload("res://Remix/Songs/Cannon Ball Z3 DS Intro.ogg")
onready var z3_cannon_ball_loop: AudioStream = preload("res://Remix/Songs/Cannon Ball Z3 DS Loop.ogg")
onready var zx_cannon_ball_intro: AudioStream = preload("res://Remix/Songs/Cannon Ball ZX Intro.ogg")
onready var zx_cannon_ball_loop: AudioStream = preload("res://Remix/Songs/Cannon Ball ZX Loop.ogg")


onready var original_x_vs_zero_intro: AudioStream = preload("res://Remix/Songs/x_vs_zero_intro.ogg")
onready var original_x_vs_zero_loop: AudioStream = preload("res://Remix/Songs/x_vs_zero_loop.ogg")
onready var x_vs_zero_breis_intro: AudioStream = preload("res://Remix/Songs/X VS ZERO Breis INTRO.ogg")
onready var x_vs_zero_breis_loop: AudioStream = preload("res://Remix/Songs/X VS ZERO Breis LOOP.ogg")
onready var x_vs_zero_intro_enhanced: AudioStream = preload("res://Remix/Songs/x_vs_zero_enhanced_intro.ogg")
onready var x_vs_zero_loop_enhanced: AudioStream = preload("res://Remix/Songs/x_vs_zero_enhanced_loop.ogg")
onready var cannon_ball_mythos_intro: AudioStream = preload("res://Remix/Songs/Cannon Ball Mythos Intro.ogg")
onready var cannon_ball_mythos_loop: AudioStream = preload("res://Remix/Songs/Cannon Ball Mythos Loop.ogg")
onready var cannon_ball_hard_revenge_intro: AudioStream = preload("res://Remix/Songs/Cannon-Ball-Hard-Revenge-Intro.ogg")
onready var cannon_ball_hard_revenge_loop: AudioStream = preload("res://Remix/Songs/Cannon-Ball-Hard-Revenge-Loop.ogg")


onready var no_sound: AudioStream = preload("res://Zero_mod/SFX/no_sound.ogg")
onready var alternate_intro_enhanced: AudioStream = preload("res://src/Sounds/OST - AlternateLumine - Intro.ogg")
onready var alternate_loop_enhanced: AudioStream = preload("res://src/Sounds/OST - AlternateLumine - Loop.ogg")
onready var original_lumine_battle_song: AudioStream = preload("res://src/Sounds/OST - Lumine - Intro.ogg")
onready var original_lumine_battle_loop: AudioStream = preload("res://src/Sounds/OST - Lumine - Loop.ogg")
onready var original_seraph_lumine_battle_song: AudioStream = preload("res://src/Sounds/OST - SeraphLumine - Intro.ogg")
onready var original_seraph_lumine_battle_loop: AudioStream = preload("res://src/Sounds/OST - SeraphLumine - Loop.ogg")
onready var original_angry_battle_song: AudioStream = preload("res://src/Sounds/OST - AngryBoss - Intro.ogg")
onready var original_angry_battle_loop: AudioStream = preload("res://src/Sounds/OST - AngryBoss - Loop.ogg")
onready var give_it_a_shot_intro: AudioStream = preload("res://Remix/Songs/GIVE_IT_A SHOT_INTRO.ogg")
onready var give_it_a_shot_loop: AudioStream = preload("res://Remix/Songs/GIVE_IT_A SHOT_LOOP.ogg")

func set_music_remix(_boss_intro, _boss_song, _angry_intro, _angry_song, _stage_intro, _stage_song, _miniboss_intro, _miniboss_song, _capsule_song, _clear_song):
	if Configurations.exists("SongRemix"):
		if Configurations.get("SongRemix"):
			if Configurations.exists("BossBattleTheme"):
				if Configurations.get("BossBattleTheme") == 0:
					music_player.boss_intro = _boss_intro
					music_player.boss_song = _boss_song
					if music_player.boss_intro != null and music_player.boss_song != null:
						music_player.boss_song.loop = true
					music_player.angry_boss_intro = _angry_intro
					music_player.angry_boss_song = _angry_song
					if music_player.angry_boss_song != null:
						music_player.angry_boss_song.loop = true
			music_player.stage_intro = _stage_intro
			music_player.stage_song = _stage_song
			if music_player.stage_song != null:
				music_player.stage_song.loop = true
			music_player.miniboss_intro = _miniboss_intro
			music_player.miniboss_song = _miniboss_song
			if music_player.miniboss_song != null:
				music_player.miniboss_song.loop = true
			music_player.capsule_song = _capsule_song
			if music_player.capsule_song != null:
				music_player.capsule_song.loop = true
			music_player.stage_clear_song = _clear_song

func _ready() -> void :
	Event.listen("music_changed", self, "change_music")
	change_music()

func change_music() -> void :
	if Configurations.exists("SongRemix"):
		if Configurations.get("SongRemix"):
			set_music()
		else:
			reset_music()

func reset_music() -> void :
			set_music_remix(
				boss_intro_save, 
				boss_loop_save, 
				angry_boss_intro_save, 
				angry_boss_loop_save, 
				stage_intro_save, 
				stage_loop_save, 
				miniboss_intro_save, 
				miniboss_loop_save, 
				capsule_loop_save, 
				stage_clear_save
			)
			
			if "NoahsPark" in level.name:
				var intro_cutscene = level.get_node_or_null("IntroCutscene")
				if intro_cutscene:
					intro_cutscene.lumine_theme.stream = _original_lumine_appears
					intro_cutscene.lumine_theme.stream.loop = true
					intro_cutscene.lumine_theme.get_node("end").stream = _original_lumine_end
					intro_cutscene.vile_theme.stream = load("")
					intro_cutscene.vile_theme.get_node("loop").stream = _original_vile_appears
					intro_cutscene.vile_theme.get_node("loop").stream.loop = true
			
			if level.name == "Inferno":
				music_player.lava_intro = _original_lava_intro
				music_player.lava_song = _original_lava_loop
				music_player.lava_song.loop = true
			
			if level.name == "MetalValley":
				music_player.stage_alt_intro = _original_alt_stage_intro
				music_player.stage_alt_loop = _original_alt_stage_loop
				music_player.stage_alt_loop.loop = true
			
			if level.name == "PitchBlack":
				music_player.alarm_intro = _original_pitchblack_alarm_intro
				music_player.alarm_song = _original_pitchblack_alarm_loop
				music_player.alarm_song.loop = true
			
			if level.name == "Gateway":
				var escape_music = level.get_node("Objects").get_node_or_null("BossWatcher")
				if escape_music:
					escape_music.final_section_intro = _original_gatewayescape_intro
					escape_music.final_section_loop = _original_gatewayescape_loop
					escape_music.final_section_loop.loop = true
			
			if level.name == "SigmaPalace":
				var sigma_demo = level.get_node("Objects").get_node_or_null("MusicStarter")
				if sigma_demo:
					sigma_demo.intro = _original_sigma_demo_intro
					sigma_demo.loop = _original_sigma_demo_loop
					sigma_demo.loop.loop = true

func set_music() -> void :
	if music_player != null:

		if "NoahsPark" in level.name:
			set_music_remix(
				_intrusion_intro, 
				_intrusion_loop, 
				_bossangry_intro, 
				_bossangry_loop, 
				_noahspark_intro, 
				_noahspark_loop, 
				_vile_intro, 
				_vile_loop, 
				_capsule, 
				_stageclear
			)
			var intro_cutscene = level.get_node_or_null("IntroCutscene")
			if intro_cutscene:
				intro_cutscene.lumine_theme.stream = _lumine_appears
				intro_cutscene.lumine_theme.stream.loop = true
				intro_cutscene.lumine_theme.get_node("end").stream = _lumine_end
				intro_cutscene.vile_theme.stream = load("")
				intro_cutscene.vile_theme.get_node("loop").stream = _vile_appears
				intro_cutscene.vile_theme.get_node("loop").stream.loop = true


		if level.name == "BoosterForest":
			set_music_remix(
				_boss_intro, 
				_boss_loop, 
				_bossangry_intro, 
				_bossangry_loop, 
				_boosterforest_intro, 
				_boosterforest_loop, 
				_vile_intro, 
				_vile_loop, 
				_capsule, 
				_stageclear
			)


		if level.name == "CentralWhite":
			set_music_remix(
				_boss_intro, 
				_boss_loop, 
				_bossangry_intro, 
				_bossangry_loop, 
				_centralwhite_intro, 
				_centralwhite_loop, 
				_mid_boss_intro, 
				_mid_boss_loop, 
				_capsule, 
				_stageclear
			)


		if level.name == "Dynasty":
			set_music_remix(
				_boss_intro, 
				_boss_loop, 
				_bossangry_intro, 
				_bossangry_loop, 
				_dynasty_intro, 
				_dynasty_loop, 
				_vile_intro, 
				_vile_loop, 
				_capsule, 
				_stageclear
			)


		if level.name == "Inferno":
			set_music_remix(
				_boss_intro, 
				_boss_loop, 
				_bossangry_intro, 
				_bossangry_loop, 
				_inferno_intro, 
				_inferno_loop, 
				_vile_intro, 
				_vile_loop, 
				_capsule, 
				_stageclear
			)
			music_player.lava_intro = _lava_intro
			music_player.lava_song = _lava_loop
			music_player.lava_song.loop = true


		if level.name == "MetalValley":
			set_music_remix(
				_boss_intro, 
				_boss_loop, 
				_bossangry_intro, 
				_bossangry_loop, 
				_metalvalley_intro, 
				_metalvalley_loop, 
				_mid_boss_intro, 
				_mid_boss_loop, 
				_capsule, 
				_stageclear
			)
			music_player.stage_alt_intro = _metalvalley2_intro
			music_player.stage_alt_loop = _metalvalley2_loop
			music_player.stage_alt_loop.loop = true

		if level.name == "PitchBlack":
			set_music_remix(
				_boss_intro, 
				_boss_loop, 
				_bossangry_intro, 
				_bossangry_loop, 
				_pitchblack_intro, 
				_pitchblack_loop, 
				_vile_intro, 
				_vile_loop, 
				_capsule, 
				_stageclear
			)
			music_player.alarm_intro = _pitchblack_alarm_intro
			music_player.alarm_song = _pitchblack_alarm_loop
			music_player.alarm_song.loop = true


		if level.name == "Primrose":
			set_music_remix(
				_boss_intro, 
				_boss_loop, 
				_bossangry_intro, 
				_bossangry_loop, 
				load(""), 
				_primrose_loop, 
				_vile_intro, 
				_vile_loop, 
				_capsule, 
				_stageclear
			)


		if level.name == "TroiaBase":
			set_music_remix(
				_boss_intro, 
				_boss_loop, 
				_bossangry_intro, 
				_bossangry_loop, 
				_troiabase_intro, 
				_troiabase_loop, 
				_vile_intro, 
				_vile_loop, 
				_capsule, 
				_stageclear
			)


		if level.name == "JakobElevator":
			set_music_remix(
				_vile_intro, 
				_vile_loop, 
				_bossangry_intro, 
				_bossangry_loop, 
				_jakobelevator_intro, 
				_jakobelevator_loop, 
				_vile_intro, 
				_vile_loop, 
				_capsule, 
				_stageclear
			)


		if level.name == "Gateway":
			set_music_remix(
				_copysigma_intro, 
				_copysigma_loop, 
				_boss_intro, 
				_boss_loop, 
				_gateway_intro, 
				_gateway_loop, 
				_vile_intro, 
				_vile_loop, 
				_capsule, 
				_stageclear
			)
			var escape_music = level.get_node("Objects").get_node_or_null("BossWatcher")
			if escape_music:
				escape_music.final_section_intro = _gatewayescape_intro
				escape_music.final_section_loop = _gatewayescape_loop
				escape_music.final_section_loop.loop = true


		if level.name == "SigmaPalace":
			set_music_remix(
				_sigmax8_intro, 
				_sigmax8_loop, 
				_bossangry_intro, 
				_bossangry_loop, 
				_sigmapalace_intro, 
				_sigmapalace_loop, 
				_vile_intro, 
				_vile_loop, 
				_capsule_final, 
				_stageclear
			)
			var sigma_demo = level.get_node("Objects").get_node_or_null("MusicStarter")
			if sigma_demo:
				sigma_demo.intro = _sigma_demo_intro
				sigma_demo.loop = _sigma_demo_loop
				sigma_demo.loop.loop = true


