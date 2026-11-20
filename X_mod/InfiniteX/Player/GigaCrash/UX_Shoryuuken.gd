extends Fall

onready var squeezebomb: = $"../Shot/SqueezeBomb"
export  var hitbox: Resource = preload("res://X_mod/UltimateX/Player/NovaStrike/NovaStrike_Hitbox.tscn")
var current_hitbox = null
var hitbox_upleft = Vector2(0, 0)
var hitbox_downright = Vector2(0, 0)
var hitbox_damage = 0
var hitbox_damage_boss = 0
var hitbox_damage_weakness = 0
var hitbox_break_guard_value = 0.25
var hitbox_break_guards: bool = true
var hitbox_rehit_time = 0.075

var hitbox_upgraded: bool = true
var hitbox_extra_damage = 1
var hitbox_extra_damage_boss = 1
var hitbox_extra_damage_weakness = 1
var hitbox_extra_break_guard_value = 1

var shoryuuken_damage = 512

var deflectable: bool = true
var ending_saber_state: bool = true
onready var arm_cannon = character.get_node("Shot")

onready var animatedSprite = character.get_node("animatedSprite")
onready var whirl_sound: AudioStreamPlayer = $whirl
onready var fire_sound: AudioStreamPlayer = $fire

var jumped: bool = false
var descend: bool = false

var start_speed = 90
var horizontal_speed = start_speed

func _ready():
	character.listen("headbump", self, "on_headbump")
	animatedSprite.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished() -> void :
	ending_saber_state = true

func reset_hitbox():
	hitbox_upleft = Vector2(0, 0)
	hitbox_downright = Vector2(0, 0)
	hitbox_damage = 0
	hitbox_damage_boss = 0
	hitbox_damage_weakness = 0
	hitbox_break_guard_value = 0.25
	hitbox_break_guards = true
	hitbox_rehit_time = 0.4
	
func set_hitbox_corners(upleft: Vector2, downright: Vector2):
	var shape = RectangleShape2D.new()
	var size = downright - upleft
	shape.extents = size / 2
	return shape
	
func spawn_hitbox(_hitbox_upleft: Vector2, _hitbox_downright: Vector2):
	current_hitbox = hitbox.instance()
	current_hitbox.name = "NovaStrikeCharged"
	var collision_shape_node = current_hitbox.get_node("collisionShape2D")
	if collision_shape_node == null:
		return
	else:
		current_hitbox.collision_shape = collision_shape_node
	
	var hitbox_shape = set_hitbox_corners(_hitbox_upleft, _hitbox_downright)
	var hitbox_position = Vector2(0, 0)
	
	var facing_direction = get_facing_direction()
	if facing_direction == - 1:
		var temp_upleft = Vector2( - _hitbox_downright.x, _hitbox_upleft.y)
		var temp_downright = Vector2( - _hitbox_upleft.x, _hitbox_downright.y)
		hitbox_shape = set_hitbox_corners(temp_upleft, temp_downright)
		hitbox_position = (temp_upleft + temp_downright) / 2
	else:
		hitbox_shape = set_hitbox_corners(_hitbox_upleft, _hitbox_downright)
		hitbox_position = (_hitbox_upleft + _hitbox_downright) / 2
	
	current_hitbox.collision_shape.shape = hitbox_shape
	current_hitbox.position = hitbox_position
	
	add_child(current_hitbox)
		
	current_hitbox.damage = hitbox_damage * hitbox_extra_damage
	current_hitbox.damage_to_bosses = hitbox_damage_boss * hitbox_extra_damage_boss
	current_hitbox.damage_to_weakness = hitbox_damage_weakness * hitbox_extra_damage_weakness
	current_hitbox.break_guards = hitbox_break_guards
	current_hitbox.upgraded = hitbox_upgraded
	current_hitbox.rehit = hitbox_rehit_time

func hitbox_and_position():
	hitbox_damage = shoryuuken_damage
	hitbox_damage_boss = shoryuuken_damage
	hitbox_damage_weakness = shoryuuken_damage
	hitbox_break_guards = true
	hitbox_rehit_time = 0.2
	if animatedSprite.frame >= 4 and animatedSprite.frame < 10:
		hitbox_upleft = Vector2( 0, - 40)
		hitbox_downright = Vector2(32, 10)
		spawn_hitbox(hitbox_upleft, hitbox_downright)
	reset_hitbox()

func end_state():
	return ending_saber_state

func invicible_frames():
	animatedSprite.material.set_shader_param("Alpha", 1)
	return animatedSprite.frame >= 0 and animatedSprite.frame < 17

func movement_speed_frames():
	return animatedSprite.frame >= 4

func on_headbump() -> void :
	if jumped:
		if animatedSprite.animation == "shoryuuken" or animatedSprite.animation == "shoryuuken_air":
			animatedSprite.frame = 17
			ending_saber_state = true

func jump_frame():
	if not jumped:
		if animatedSprite.frame >= 4:
			character.set_vertical_speed( - jump_velocity)
			jumped = true
			whirl_sound.play()
			fire_sound.play()

func _StartCondition() -> bool:
	if not squeezebomb.has_max_ammo():
		return false
	if not arm_cannon.shoryuuken:
		return false
	if character.get_action_pressed("select_special"):
		return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	if not animatedSprite.animation == "shoryuuken" and not animatedSprite.animation == "shoryuuken_air":
		return true
	if end_state() and character.get_vertical_speed() >= 0:
		return true
	return false

func _Setup() -> void :
	squeezebomb.reduce_all_ammo()
	character.can_eject = false
	ending_saber_state = false
	start_speed = 250
	jump_velocity = 600
	horizontal_speed = start_speed
	update_bonus_horizontal_only_conveyor()
	jumped = false
	descend = false
	if character.is_on_floor():
		animatedSprite.animation = "shoryuuken"
	if not character.is_on_floor():
		animatedSprite.animation = "shoryuuken_air"

func _Update(_delta: float) -> void :
	if jumped:
		process_gravity(_delta)

	jump_frame()
	hitbox_and_position()
	if movement_speed_frames():
		force_movement(horizontal_speed)
	else:
		force_movement(0)

	if invicible_frames():
		character.add_invulnerability("Shoryuuken")
	else:
		character.remove_invulnerability("Shoryuuken")
		
	if animatedSprite.frame >= 7:
		horizontal_speed = 150

func change_animation_if_falling(_s) -> void :
	animatedSprite.animation = "fall"

func _Interrupt():
	character.can_eject = true
	character.remove_invulnerability("Shoryuuken")
	animatedSprite.animation = "fall"
	if is_instance_valid(current_hitbox):
		current_hitbox.queue_free()

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
