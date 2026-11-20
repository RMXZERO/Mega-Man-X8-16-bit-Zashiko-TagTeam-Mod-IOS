extends GenericIntro

onready var overlay: AnimatedSprite = $"../overlay"
onready var song: AudioStreamPlayer = $song
onready var tween: = TweenController.new(self, false)
onready var battle_song: AudioStreamPlayer = $BattleSong
onready var battle_2_song: AudioStreamPlayer = $"../BossDeath/Desperation"
onready var effect: AudioStreamPlayer = $effect
onready var damage: Node2D = $"../Damage"
onready var space: Node = $"../Space"

export  var bar: Texture

func _ready() -> void :
	call_deferred("play_animation", "intro")
	call_deferred("set_music")
	make_invisible()
	Event.listen("character_talking", self, "talk")

func set_music() -> void :
	var current_scene = get_tree().current_scene
	var remix = current_scene.get_node_or_null("Remix")
	if current_scene and remix:
		if Configurations.exists("SongRemix"):
			if Configurations.get("SongRemix"):
				song.stream = remix._intro_demake
				song.stream.loop = true
				battle_song.stream = remix._song_rmexe3_boss_intro
				battle_song.get_node("loop").stream = remix._song_rmexe3_boss_loop
				battle_song.get_node("loop").stream.loop = true
				battle_2_song.stream = remix._song_rmexe6_cybeasts_intro
				battle_2_song.get_node("loop").stream = remix._song_rmexe6_cybeasts_loop
				battle_2_song.get_node("loop").stream.loop = true

func talk(character):
	if character == "Secret2":
		play_animation_once("talk")
	else:
		play_animation_once("intro")

func connect_start_events() -> void :
	Log("Connecting boss door events")
	Event.listen("teleport_to_secret2", self, "prepare_for_intro")
	Event.listen("end_teleport_to_secret2", self, "execute_intro")

func _Setup():
	GlobalVariables.add("serenade_seen", "seen")
	animatedSprite.visible = false
	Tools.timer(2.0, "start_intro", self)
	GameManager.start_cutscene()
	GameManager.dialog_box.emit_capsule_signal = false
	turn_player_towards_boss()

func start_intro():
	song.play()
	Tools.timer(2.0, "fadein", self)
	
func fadein():
	animatedSprite.visible = true
	tween.attribute("modulate:a", 1.0, 2.0, overlay)
	tween.add_callback("make_visible")
	tween.add_attribute("modulate:a", 0.0, 2.0, overlay)
	tween.add_callback("next_attack_stage")

func _Update(_delta):
	if attack_stage == 1:
		start_dialog_or_go_to_attack_stage(3)

	elif attack_stage == 2:
		if seen_dialog():
			next_attack_stage()

	elif attack_stage == 3:
		play_animation("intro_end")
		song.stop()
		effect.play()
		next_attack_stage()
		
	elif attack_stage == 4 and timer > 1.1:
		Event.emit_signal("set_boss_bar", bar)
		Event.emit_signal("boss_health_appear", character)
		next_attack_stage()
		
	elif attack_stage == 5 and timer > 1.2:
		battle_song.play()
		damage.can_get_hit = true
		EndAbility()
	pass

func _Interrupt():
	Event.emit_signal("boss_start", character)
	GameManager.end_cutscene()
	character.emit_signal("intro_concluded")
	animatedSprite.modulate.a = 1.0
	space.define_arena()
