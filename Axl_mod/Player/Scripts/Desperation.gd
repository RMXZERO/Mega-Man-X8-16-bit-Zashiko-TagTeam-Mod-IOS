extends FallAxl

onready var desperation: PackedScene = preload("res://Axl_mod/Player/Projectiles/Desperation.tscn")
var creator: Node2D

var ending_saber_state: bool = true

onready var giga_crash: = $"../Special/GigaCrash"
onready var animatedSprite = character.get_node("animatedSprite")
onready var animatedSpriteAxl = $animatedSpriteAxl
onready var victory_sound: AudioStreamPlayer2D = $victory

var ready_played: bool = false
var create_slash: bool = false
var slash_end: bool = false
var slash_end_2: bool = false
var slash_end_3: bool = false
var desperation_reduce_ammo = 1.0
var desperation_damage = 3
var desperation_speed = 400

func _ready():
	end_state()

func _on_animation_finished() -> void :
	ending_saber_state = true

func end_state() -> void :
	CharacterManager.xdrive = false

func _StartCondition() -> bool:
	if not CharacterManager.player_desperation:
		return false
	if CharacterManager.xdrive:
		return false
	if not character.is_on_floor():
		return false
	if not character.get_action_pressed("move_up"):
		return false
	if character.get_action_pressed("select_special"):
		return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	if slash_end_3:
		return true
	if not animatedSprite.animation == "victory":
		return true
	return false

func _Setup() -> void :
	ending_saber_state = false
	ready_played = false
	create_slash = false
	slash_end = false
	slash_end_2 = false
	slash_end_3 = false
	animatedSpriteAxl.animation = "fire_loop"
	animatedSpriteAxl.frame = 0
	animatedSpriteAxl.scale = animatedSprite.scale
	character.listening_to_inputs = false
	if character.is_on_floor():
		animatedSprite.animation = "victory"

func _Update(_delta: float) -> void :
	set_horizontal_speed(0)
	process_gravity(_delta)
	if animatedSprite.animation == "victory":
		if animatedSprite.frame >= 8:
			if not ready_played:
				victory_sound.play()
				ready_played = true
		if animatedSprite.frame >= 20:
			giga_crash.stop_recover = true
			character.can_eject = false
			animatedSprite.position.y = 400
			animatedSpriteAxl.show()
			create_desperation()
			if Input.is_action_pressed("select_special") and not slash_end_2:
				CharacterManager.xdrive = true
				slash_end_2 = true

func create_desperation():
	if giga_crash.current_ammo <= 1 and not slash_end or slash_end_2 or CharacterManager.xdrive:
		slash_end_2 = false
		slash_end = true
		animatedSpriteAxl.animation = "fire_idle"
		animatedSpriteAxl.frame = 0
		CharacterManager.xdrive = false
		Tools.timer(0.5, "fire_end", self)
	if not create_slash:
		create_slash = true
		var instance = desperation.instance()
		get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
		instance.damage = desperation_damage
		instance.damage_to_bosses = desperation_damage
		instance.damage_to_weakness = desperation_damage
		instance.desperation_speed = desperation_speed
		instance.set_global_position(global_position)
		instance.set_creator(creator)
		instance.call_deferred("initialize", get_facing_direction())

func fire_end() -> void :
	animatedSpriteAxl.animation = "fire_end"
	animatedSpriteAxl.frame = 0
	Tools.timer(0.1, "slash_end_ability", self)

func slash_end_ability() -> void :
	slash_end_3 = true

func change_animation_if_falling(_s) -> void :
	if not character.is_on_floor():
		animatedSprite.animation = "fall"
	else:
		animatedSprite.animation = "recover"

func _Interrupt():
	character.can_eject = true
	giga_crash.stop_recover = false
	animatedSprite.position.y = -4
	animatedSpriteAxl.hide()
	slash_end = true
	slash_end_2 = true
	slash_end_3 = true
	CharacterManager.xdrive = true
	end_state()
	if GameManager.state == "Normal":
		character.listening_to_inputs = true
	if not character.is_on_floor():
		animatedSprite.animation = "fall"
	else:
		animatedSprite.animation = "recover"

func Initialize() -> void :
	executing = true
	timer = 0
	last_time_used = get_time()
	character.executing_moves.append(self)
	emit_signal("executed")
	play_sound_on_initialize()
	play_animation_on_initialize()

func BeforeEveryFrame(_delta: float) -> void :
	pass
