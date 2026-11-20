extends GenericIntro

onready var floppy: Node2D = $"../Floppy"
export  var bar: Texture
onready var battle_song: AudioStreamPlayer = $BattleSong
onready var song: AudioStreamPlayer = $song

func _ready() -> void :
	call_deferred("play_animation", "analysing")
	call_deferred("set_music")
	Event.listen("character_talking", self, "talk")
	floppy.call_deferred("appear")
	song.stream.loop = true

func set_music() -> void :
	var current_scene = get_tree().current_scene
	var remix = current_scene.get_node_or_null("Remix")
	if current_scene and remix:
		if Configurations.exists("SongRemix"):
			if CharacterManager.game_mode >= 2:
				if Configurations.get("SongRemix"):
					song.stream = remix._intro_red_demake
					song.stream.loop = true
					battle_song.stream = remix._song_sigma_x7_intro
					battle_song.get_node("loop").stream = remix._song_sigma_x7_loop
					battle_song.get_node("loop").stream.loop = true
				else:
					song.stream = remix._original_intro_red
					song.stream.loop = true
					battle_song.stream = remix._original_song_sigma_x7_intro
					battle_song.get_node("loop").stream = remix._original_song_sigma_x7_loop
					battle_song.get_node("loop").stream.loop = true
			else:
				if Configurations.get("SongRemix"):
					song.stream = remix._intro_red_demake
					song.stream.loop = true
					battle_song.stream = remix._song_red_intro
					battle_song.get_node("loop").stream = remix._song_red_loop
					battle_song.get_node("loop").stream.loop = true
				else:
					song.stream = remix._original_intro_red
					song.stream.loop = true
					battle_song.stream = remix._original_song_red_intro
					battle_song.get_node("loop").stream = remix._original_song_red_loop
					battle_song.get_node("loop").stream.loop = true

func talk(character):
	if executing:
		if character == "Secret3":
			play_animation_once("analysing_talk")
		else:
			play_animation_once("analysing")

func connect_start_events() -> void :
	Log("Connecting boss door events")
	Event.listen("teleport_to_red", self, "prepare_for_intro")
	Event.listen("end_teleport_to_red", self, "execute_intro")
	Event.listen("character_switch", self, "false_only_axl")
	Event.connect("player_death", self, "false_only_axl")

func false_only_axl() -> void :
	CharacterManager.only_axl = false

func _Setup():
	GlobalVariables.set("red_seen", true)
	turn_player_towards_boss()
	GameManager.start_cutscene()
	GameManager.dialog_box.emit_capsule_signal = false
	next_attack_stage()
	if not seen_dialog():
		song.play()
	if CharacterManager.game_mode >= 3:
		if CharacterManager.player_character == "Axl":
			CharacterManager.only_axl = true

func _Update(_delta):
	if attack_stage == 1 and timer > 2:
		start_dialog_or_go_to_attack_stage(3)

	elif attack_stage == 2:
		if seen_dialog():
			next_attack_stage()
	
	elif attack_stage == 3:
		floppy.disappear()
		song.stop()
		battle_song.loop.stream.loop = true
		battle_song.play()
		next_attack_stage()
		
	elif attack_stage == 4 and timer > 0.7:
		play_animation("analysing_end")
		next_attack_stage()
		
	elif attack_stage == 5 and timer > 0.7:
		play_animation("turn")
		next_attack_stage()
		
	elif attack_stage == 6 and timer > 0.7:
		play_animation("ready")
		Event.emit_signal("set_boss_bar", bar)
		Event.emit_signal("boss_health_appear", character)
		next_attack_stage()
		
	elif attack_stage == 7 and timer > 1:
		EndAbility()

func _Interrupt():
	Event.emit_signal("boss_start", character)
	GameManager.end_cutscene()
	character.emit_signal("intro_concluded")
	animatedSprite.modulate.a = 1.0
	floppy.disappear()
