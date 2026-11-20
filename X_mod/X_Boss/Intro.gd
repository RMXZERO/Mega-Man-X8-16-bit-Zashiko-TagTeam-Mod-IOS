extends GenericIntro

onready var main = get_parent()

onready var tween: TweenController = TweenController.new(self, false)
onready var battle_song: AudioStreamPlayer = $BattleSong
onready var song: AudioStreamPlayer = $song
onready var dmg: Node2D = $"../Damage"
onready var damage: Node2D = $"../DamageOnTouch"
export  var bar: Texture
onready var sfx_dash: AudioStreamPlayer = get_parent().get_node("dash")
onready var sfx_jump: AudioStreamPlayer = get_parent().get_node("jump")
onready var sfx_land: AudioStreamPlayer = get_parent().get_node("land")

var time_offset: float = 0.0
var amplitude: float = 2.0
var speed: float = 0.5
var beam_speed: float = 420

const sprite_y := -4.0
onready var beam_in: AudioStreamPlayer2D = $beam_in
onready var copy_x_laugh: AudioStreamPlayer2D = $copy_x_laugh

func connect_start_events() -> void :
	Event.listen("teleport_to_secretboss", self, "prepare_for_intro")
	Event.listen("end_teleport_to_secretboss", self, "execute_intro")
	
func _ready() -> void :
	call_deferred("prepare_for_intro")
	Event.listen("character_talking", self, "talk")
	set_music()
	if CharacterManager.player_character == "Zero":
		call_deferred("play_animation", "beam_special")
		speed = 0.25
		beam_speed = 840
	else:
		call_deferred("play_animation", "beam")
	
func set_music() -> void :
	var current_scene = get_tree().current_scene
	var remix = current_scene.get_node_or_null("Remix")
	if current_scene and remix:
		if CharacterManager.game_mode > 2 and Input.is_action_pressed("alt_fire"):
			battle_song.stream = remix.x_vs_zero_intro_enhanced
			battle_song.get_node("loop").stream = remix.x_vs_zero_loop_enhanced
		elif CharacterManager.game_mode > 2 and not Input.is_action_pressed("alt_fire"):
			battle_song.stream = remix.x_vs_zero_breis_intro
			battle_song.get_node("loop").stream = remix.x_vs_zero_breis_loop
		if Configurations.exists("SongRemix"):
			if Configurations.get("SongRemix"):
				battle_song.stream = remix.z3_x_vs_zero_intro_enhanced
				battle_song.get_node("loop").stream = remix.z3_x_vs_zero_loop_enhanced
				song.stream = remix._x_the_legend
	song.stream.loop = true

func prepare_for_intro() -> void :
	animatedSprite.position = Vector2(0,-256)
	animatedSprite.frame = 0

func talk(character):
	if executing:
		if main.only_x:
			if character == "X_Boss":
				play_animation_once("talk_3")
			else:
				play_animation_once("idle_3")
		else:
			if character == "X_Boss":
				play_animation_once("talk_2")
			else:
				play_animation_once("idle_2")

func _Setup():
	GameManager.start_cutscene()
	GameManager.dialog_box.emit_capsule_signal = false
	Tools.timer(1.0, "attack_stage_1", self)
	turn_player_towards_boss()
	GameManager.add_collectible_to_savedata("x_seen")
	if not CharacterManager.fight_boss_2:
		song.play()

func attack_stage_1() -> void :
	go_to_attack_stage(1)

func _Update(delta):
	if attack_stage == 0 and timer > 0.5:
		pass
	
	elif attack_stage == 1 and timer > 0.5:
		if main.only_zero:
			play_animation_once("beam_special")
		else:
			play_animation_once("beam")
		turn_player_towards_boss()
		turn_and_face_player()
		tween_attribute("position:y", sprite_y, speed, animatedSprite)
		beam_in.play()
		next_attack_stage()
	
	elif attack_stage == 2:
		if animatedSprite.position.y >= -4:
			set_vertical_speed(beam_speed)
			if character.is_on_floor():
				if main.only_zero:
					play_animation_again("beam_in_special")
				else:
					play_animation_again("beam_in")
				next_attack_stage()
	
	elif attack_stage == 3 and has_finished_last_animation():
		if not CharacterManager.fight_boss_2:
			if main.only_x:
				if not seen_dialog():
					play_animation("idle_3")
				else:
					play_animation("idle_2")
				start_dialog_or_go_to_attack_stage(5)
			elif main.only_axl:
				play_animation("idle_2")
				start_special_dialog_or_go_to_attack_stage("axl_seen_x_boss", 5)
			elif main.only_zero:
				play_animation("idle_2")
				start_special_dialog_or_go_to_attack_stage("zero_seen_x_boss", 5)
		if CharacterManager.fight_boss_2:
			if CharacterManager.weaponget:
				go_to_attack_stage(5)
		
	elif attack_stage == 4:
		if not CharacterManager.fight_boss_2:
			if main.only_x:
				if seen_dialog():
					next_attack_stage()
			elif main.only_zero:
				if seen_special_dialog("zero_seen_x_boss"):
					next_attack_stage()
			elif main.only_axl:
				if seen_special_dialog("axl_seen_x_boss"):
					next_attack_stage()
		if CharacterManager.fight_boss_2:
			go_to_attack_stage(5)
		
	elif attack_stage == 5 and has_finished_last_animation():
		if main.only_zero:
			copy_x_laugh.play()
		play_animation("beam_equip")
		screenshake(1.0)
		song.stop()
		if not CharacterManager.fight_boss_2:
			battle_song.loop.stream.loop = true
			battle_song.play()
		Event.emit_signal("show_life_steal_bar")
		next_attack_stage()

	elif attack_stage == 6 and timer > 1.0:
		if not CharacterManager.fight_boss_2:
			Event.emit_signal("set_boss_bar", bar)
			Event.emit_signal("boss_health_appear", character)
		if CharacterManager.fight_boss_2:
			Event.emit_signal("is_boss_2", character.name)
		CharacterManager.weaponget = false
		if CharacterManager.nightshade_zero_armor:
			character.max_health = 512
			character.current_health = 512
		next_attack_stage()

	elif attack_stage == 7 and timer > 1.2:
		EndAbility()

func start_special_dialog_or_go_to_attack_stage(dialog_collectible: String, skip_dialog_stage: = 0) -> void :
	dialogue = CharacterManager._set_correct_dialogues(get_parent().name, dialogue)
	if dialogue:
		connect_dialogue()
	if dialog_collectible in GameManager.collectibles:
		go_to_attack_stage(skip_dialog_stage)
	elif not dialog_collectible in GameManager.collectibles:
		GameManager.add_collectible_to_savedata(dialog_collectible)
		GameManager.start_dialog(dialogue)
		next_attack_stage()

func seen_special_dialog(dialog_collectible: String) -> bool:
	if not dialog_collectible in GameManager.collectibles:
		return false
	return GameManager.was_dialogue_seen(dialogue)
