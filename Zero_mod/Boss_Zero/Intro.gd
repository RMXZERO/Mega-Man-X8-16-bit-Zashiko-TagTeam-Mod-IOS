extends GenericIntro

onready var tween: TweenController = TweenController.new(self, false)
onready var battle_song: AudioStreamPlayer = $BattleSong
onready var song: AudioStreamPlayer = $song
onready var dmg: Node2D = $"../Damage"
onready var damage: Node2D = $"../DamageOnTouch"
export  var bar: Texture
onready var effect: = animatedSprite.get_node("effectSprite")
onready var sfx_dash: AudioStreamPlayer = get_parent().get_node("dash")
onready var sfx_jump: AudioStreamPlayer = get_parent().get_node("jump")
onready var sfx_land: AudioStreamPlayer = get_parent().get_node("land")

onready var main: = get_parent()
onready var sfx_awake: = $sfx_awake
onready var awakened_sfx: = get_parent().get_node("awakened_sfx")
onready var reflector: Node2D = $"../DamageReflector"
onready var deflect: Node2D = $"../Deflect"

var time_offset: float = 0.0
var amplitude: float = 2.0
var speed: float = 1.0

onready var collision_shape: = get_parent().get_node("collisionShape2D")


func connect_start_events() -> void :
	Event.listen("teleport_to_secretboss", self, "prepare_for_intro")
	Event.listen("end_teleport_to_secretboss", self, "execute_intro")
	
func _ready() -> void :
	call_deferred("prepare_for_intro")
	Event.listen("character_talking", self, "talk")
	song.stream.loop = true
	awakened_sfx.stream.loop = true
	set_music()

func set_music() -> void :
	var current_scene = get_tree().current_scene
	var remix = current_scene.get_node_or_null("Remix")
	if current_scene and remix:
		if Configurations.exists("SongRemix"):
			if Configurations.get("SongRemix"):
				if CharacterManager.player_character == "Zero":
					battle_song.stream = remix.z3_cannon_ball_intro
					battle_song.get_node("loop").stream = remix.z3_cannon_ball_loop
				else:
					battle_song.stream = remix.z3_x_vs_zero_intro_enhanced
					battle_song.get_node("loop").stream = remix.z3_x_vs_zero_loop_enhanced
			else:
				if CharacterManager.game_mode > 2 and not Input.is_action_pressed("alt_fire"):
					battle_song.stream = remix.x_vs_zero_intro_enhanced
					battle_song.get_node("loop").stream = remix.x_vs_zero_loop_enhanced
				elif CharacterManager.game_mode > 2 and Input.is_action_pressed("alt_fire"):
					battle_song.stream = remix.x_vs_zero_breis_intro
					battle_song.get_node("loop").stream = remix.x_vs_zero_breis_loop
				if CharacterManager.player_character == "Zero":
					battle_song.stream = remix.cannon_ball_mythos_intro
					battle_song.get_node("loop").stream = remix.cannon_ball_mythos_loop

func prepare_for_intro() -> void:
	effect.visible = true
	call_deferred("play_animation", "intro")
	animatedSprite.position = Vector2(0,-400)

func talk(character):
	if executing:
		if character == "Zero_Boss":
			play_animation_once("talk")
		else:
			play_animation_once("idle")

func _Setup():
	GameManager.start_cutscene()
	GameManager.dialog_box.emit_capsule_signal = false
	turn_player_towards_boss()
	awakened_sfx.play()
	GameManager.add_collectible_to_savedata("zero_seen")
	song.play()

func _Update(delta):
	if attack_stage == 0:
		set_vertical_speed(50)
		reflector.deflects_max = 4
		reflector.deflects = reflector.deflects_max
		reflector.reset()
		reflector.activate()
		damage.activate()
		dmg.deactivate()
		dmg.remove_weaknesses()
		next_attack_stage()
		
	if attack_stage == 1:
		time_offset += delta * speed * 5
		animatedSprite.offset.y = 1 + amplitude * sin(time_offset)
		reflector.start = false
		if animatedSprite.position.y < -4:
			animatedSprite.position.y += delta * 50
		if character.is_on_floor():
			set_vertical_speed(0)
		if character.is_on_floor() and animatedSprite.position.y >= -4:
			animatedSprite.position.y = -4
			animatedSprite.offset.y = 1
			play_animation("intro_land")
			sfx_land.play()
			next_attack_stage()
		
	if attack_stage == 2 and has_finished_last_animation():
		play_animation("idle")
		if not CharacterManager.fight_boss_2:
			start_dialog_or_go_to_attack_stage(3)
		else:
			go_to_attack_stage(7)

	elif attack_stage == 3:
		if seen_dialog():
			next_attack_stage()
			play_animation("awakened_start")

	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("awakened_loop")
		screenshake(1.0)
		sfx_awake.play()
		song.stop()
		if not CharacterManager.fight_boss_2:
			battle_song.loop.stream.loop = true
			battle_song.play()
		
		next_attack_stage()

	elif attack_stage == 5 and timer > 1.0:
		if not CharacterManager.fight_boss_2:
			Event.emit_signal("set_boss_bar", bar)
			Event.emit_signal("boss_health_appear", character)
		if CharacterManager.fight_boss_2:
			Event.emit_signal("is_boss_2", character.name)
		if CharacterManager.nightshade_zero_armor:
			character.max_health = 1024
			character.current_health = 1024
		next_attack_stage()

	elif attack_stage == 6 and timer > 1.2:
		dmg.call_deferred("deactivate")
		EndAbility()

	elif attack_stage == 7:
		CharacterManager.weaponget = true
		play_animation("awakened_start")
		go_to_attack_stage(4)

func _Interrupt():
	character.emit_signal("damage_reduction", 1.0)
	._Interrupt()
	reflector.start = true
	if main.only_zero:
		reflector.start = false
		reflector.deflects = 0
		reflector.activate_damage()
		deflect.deactivate()
		dmg.call_deferred("activate")
		damage.call_deferred("activate")
