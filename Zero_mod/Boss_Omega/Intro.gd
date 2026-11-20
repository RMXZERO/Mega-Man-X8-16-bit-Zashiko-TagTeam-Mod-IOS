extends GenericIntro

onready var main = get_parent()
onready var boss_2_bar = get_parent().get_node("HPSprite").get_node("Boss Bar")
onready var tween: TweenController = TweenController.new(self, false)
onready var battle_song: AudioStreamPlayer = $BattleSong
onready var song: AudioStreamPlayer = $song
export  var bar: Texture
export  var bar2: Texture
onready var sfx_dash: AudioStreamPlayer = get_parent().get_node("dash")
onready var sfx_jump: AudioStreamPlayer = get_parent().get_node("jump")
onready var sfx_land: AudioStreamPlayer = get_parent().get_node("land")

onready var beam_in: AudioStreamPlayer2D = $beam_in
onready var messiah: AudioStreamPlayer2D = $messiah

var time_offset: float = 0.0
var amplitude: float = 2.0
var speed: float = 0.5
var beam_speed: float = 420
var start_beam_in: bool = false

onready var slash_combo = character.get_node("7SlashCombo")

const sprite_y := -4.0


func connect_start_events() -> void :
	Event.listen("teleport_to_secretboss", self, "prepare_for_intro")
	Event.listen("end_teleport_to_secretboss", self, "execute_intro")
	
func _ready() -> void :
	call_deferred("prepare_for_intro")
	call_deferred("set_music")
	Event.listen("character_talking", self, "talk")
	song.stream.loop = true
	start_beam_in = false

func set_music() -> void :
	var current_scene = get_tree().current_scene
	var remix = current_scene.get_node_or_null("Remix")
	if current_scene and remix:
		if Configurations.exists("SongRemix"):
			if Configurations.get("SongRemix"):
				if CharacterManager.player_character == "X":
					battle_song.stream = remix.z3_x_vs_zero_intro_enhanced
					battle_song.get_node("loop").stream = remix.z3_x_vs_zero_loop_enhanced
				else:
					battle_song.stream = remix.zx_cannon_ball_intro
					battle_song.get_node("loop").stream = remix.zx_cannon_ball_loop
			else:
				if CharacterManager.game_mode > 2:
					battle_song.stream = remix.x_vs_zero_breis_intro
					battle_song.get_node("loop").stream = remix.x_vs_zero_breis_loop
				if not CharacterManager.player_character == "X":
					battle_song.stream = remix.cannon_ball_hard_revenge_intro
					battle_song.get_node("loop").stream = remix.cannon_ball_hard_revenge_loop

func prepare_for_intro() -> void :
	if CharacterManager.player_character == "X":
		call_deferred("play_animation", "beam")
		animatedSprite.position = Vector2(0,-256)
	else:
		call_deferred("play_animation", "messiah_flash")
		animatedSprite.position = Vector2(0,-4)
	animatedSprite.frame = 0

func talk(character):
	if executing:
		if main.only_x:
			if character == "Omega_Zero":
				play_animation_once("talk")
			else:
				play_animation_once("idle")

func _Setup():
	GameManager.start_cutscene()
	GameManager.dialog_box.emit_capsule_signal = false
	turn_player_towards_boss()
	GameManager.add_collectible_to_savedata("omega_seen")
	Tools.timer(2, "start_beam", self)
	if CharacterManager.player_character == "X":
		song.play()

func start_beam():
	start_beam_in = true
	main.dash_afterimages()

func _Update(delta):
	if attack_stage == 0:
		if main.only_x:
			if start_beam_in:
				play_animation_once("beam")
				turn_player_towards_boss()
				turn_and_face_player()
				tween_attribute("position:y", sprite_y, speed, animatedSprite)
				beam_in.play()
				next_attack_stage()
		else:
			play_animation_once("messiah_flash")
			timer = 0
			go_to_attack_stage(8)
		
	if attack_stage == 1:
		if animatedSprite.position.y >= -4:
			set_vertical_speed(beam_speed)
			if character.is_on_floor():
				play_animation_again("beam_in")
				next_attack_stage()
		
	if attack_stage == 2 and has_finished_last_animation():
		play_animation("beam_equip")
		next_attack_stage()

	if attack_stage == 3 and has_finished_last_animation():
		play_animation("idle")
		start_dialog_or_go_to_attack_stage(5)

	elif attack_stage == 4:
		if seen_dialog():
			next_attack_stage()

	elif attack_stage == 5 and has_finished_last_animation():
		song.stop()
		if not CharacterManager.fight_boss_2:
			battle_song.loop.stream.loop = true
			battle_song.play()
		if main.only_axl:
			hit_axl()
		next_attack_stage()

	elif attack_stage == 6 and timer > 1.0:
		if not CharacterManager.fight_boss_2:
			if main.only_x:
				Event.emit_signal("set_boss_bar", bar)
			else:
				Event.emit_signal("set_boss_bar", bar2)
			Event.emit_signal("boss_health_appear", character)
		if CharacterManager.fight_boss_2:
			if main.only_x:
				boss_2_bar.set_boss_bar(bar)
			else:
				boss_2_bar.set_boss_bar(bar2)
			Event.emit_signal("is_boss_2", character.name)
		next_attack_stage()

	elif attack_stage == 7 and timer > 1.2:
		EndAbility()

	elif attack_stage == 8 and timer > 2:
		play_animation_once("messiah_end")
		messiah.play()
		timer = 0
		next_attack_stage()

	elif attack_stage == 9 and timer > 0.5:
		main.flash_afterimages()
		go_to_attack_stage(5)


func _Interrupt():
	._Interrupt()
	use_7_slash_combo_at_first()

func use_7_slash_combo_at_first() -> void:
	if not main.only_axl:
		return
	if start_beam_in:
		start_beam_in = false
		character.interrupt_all_moves()
		slash_combo.Initialize()
		slash_combo._Setup()
		yield(get_tree().create_timer(1.0), "timeout")
		GameManager.dialog_box.force_end()

func hit_axl():
	dialogue = preload("res://Zero_mod/Boss_Omega/Dialogue/OmegaZero_Dialogue_Axl.tres")
	if dialogue:
		connect_dialogue()
	if not seen_dialog():
		GameManager.start_dialog(dialogue)
