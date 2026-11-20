extends Fall

export  var saber_hitbox: Resource = preload("res://X_mod/UltimateX/Player/NovaStrike/NovaStrike_Hitbox.tscn")
export  var damage: float = 4.0
export  var damage_boss: float = 4.0
export  var damage_weakness: float = 24.0
export  var hitbox_break_guards: bool = false

onready var animatedSprite: = character.get_node("animatedSprite")
onready var saber_sound: AudioStreamPlayer = $saber

var current_hitbox = null
var hitbox_upleft: Vector2 = Vector2(0, 0)
var hitbox_downright: Vector2 = Vector2(0, 0)
var hitbox_damage: float = 0
var hitbox_damage_boss: float = 0
var hitbox_damage_weakness: float = 0
var hitbox_break_guard_value: float = 0.4
var hitbox_rehit_time: float = 0.05
var hitbox_upgraded: bool = false
var hitbox_extra_damage: float = 1
var hitbox_extra_damage_boss: float = 1
var hitbox_extra_damage_weakness: float = 1
var hitbox_extra_break_guard_value: float = 1
var deflectable: bool = false
var deflectable_type: int = 0
var only_deflect_weak: bool = false

var saber_damage = 24

var ending_saber_state: bool = false
var saber_sound_counter: int = 0
var slashing: bool = false
var slashes: int = 0
var landed: bool = false
var vertical_last: float = 0
var input_buffer: Array = []
var buffer_window_threshold: int = 2

onready var arm_cannon = character.get_node("Shot")

func _ready() -> void :
	animatedSprite.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished() -> void :
	ending_saber_state = true

func reset_hitbox() -> void :
	hitbox_upleft = Vector2(0, 0)
	hitbox_downright = Vector2(0, 0)
	hitbox_damage = 0
	hitbox_damage_boss = 0
	hitbox_damage_weakness = 0
	hitbox_break_guard_value = 0.4

func set_hitbox_corners(upleft: Vector2, downright: Vector2) -> RectangleShape2D:
	var shape = RectangleShape2D.new()
	var size = downright - upleft
	shape.extents = size / 2
	return shape

func spawn_hitbox(_hitbox_upleft: Vector2, _hitbox_downright: Vector2) -> void :
	current_hitbox = saber_hitbox.instance()
	current_hitbox.name = "NovaStrikeCharged"
	var collision_shape_node = current_hitbox.get_node("collisionShape2D")
	var deflection_shape_node = current_hitbox.get_node("area2D/collisionShape2D")
	if collision_shape_node == null:
		return
	else:
		current_hitbox.collision_shape = collision_shape_node
	if deflection_shape_node == null:
		return
	else:
		current_hitbox.deflection_shape = deflection_shape_node
	
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
	current_hitbox.deflection_shape.shape = hitbox_shape
	current_hitbox.position = hitbox_position
	
	add_child(current_hitbox)
		
	current_hitbox.damage = hitbox_damage * hitbox_extra_damage
	current_hitbox.damage_to_bosses = hitbox_damage_boss * hitbox_extra_damage_boss
	current_hitbox.damage_to_weakness = hitbox_damage_weakness * hitbox_extra_damage_weakness
	current_hitbox.break_guards = hitbox_break_guards
	current_hitbox.upgraded = hitbox_upgraded
	current_hitbox.rehit = hitbox_rehit_time

func hitbox_and_position() -> void :
	hitbox_damage = saber_damage
	hitbox_damage_boss = saber_damage
	hitbox_damage_weakness = saber_damage
	hitbox_break_guards = true
	hitbox_rehit_time = 0.1
	if animatedSprite.frame >= 3 and animatedSprite.frame < 9:
		hitbox_upleft = Vector2( -22, - 40)
		hitbox_downright = Vector2(50, 10)
		spawn_hitbox(hitbox_upleft, hitbox_downright)
	reset_hitbox()

func end_saber_state() -> bool:
	return ending_saber_state

func is_in_buffer_window() -> bool:
	return false

func should_add_saber_combo() -> bool:
	return false

func set_saber_animations() -> void :
	if not character.is_on_floor():
		animatedSprite.animation = "saber_jump"
		animatedSprite.frame = 0
		saber_sound.play()
	if character.is_on_floor():
		animatedSprite.animation = "saber_land"
		animatedSprite.frame = 0
		saber_sound.play()

func _StartCondition() -> bool:
	if not arm_cannon.saber:
		return false
	if character.get_action_pressed("move_up") and character.is_on_floor():
		return false
	if character.get_action_pressed("select_special"):
		return true
	if not executing:
		if not character.is_on_floor():
			vertical_last = character.velocity.y
			return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	if not animatedSprite.animation == "saber_land" and not animatedSprite.animation == "saber_jump":
		return true
	if end_saber_state():
		return true
	return false

func _Setup() -> void :
	$"../AirDash/dash_particle".hide()
	$"../AirDash/duringImage".hide()
	$"../Dash/dash_particle".hide()
	$"../Dash/duringImage".hide()
	landed = false
	if vertical_last != 0:
		character.velocity.y = vertical_last
	set_saber_animations()
	if character.dashjumps_since_jump > 0:
		horizontal_velocity = dash_momentum
		character.dashjump_signal()
	else:
		horizontal_velocity = 120
	ending_saber_state = false

func _Update(_delta: float) -> void :
	hitbox_and_position()
	
	if is_in_buffer_window() and character.get_action_just_pressed(actions[0]):
		input_buffer.append(actions[0])
	
	if should_add_saber_combo() and input_buffer.size() > 0:
		input_buffer.pop_front()
		set_saber_animations()

	if not character.is_executing("WallJump") and not character.is_executing("DashWallJump"):
		process_gravity(_delta)
	
	if character.dashfall:
		set_movement_and_direction(dash_momentum, _delta)
	else:
		set_movement_and_direction(horizontal_velocity, _delta)

	var animation_frame = animatedSprite.frame
	if character.is_on_floor():
		if not landed:
			animatedSprite.animation = "saber_land"
			animatedSprite.frame = animation_frame
			landed = true
		set_movement_no_direction(0)
		update_bonus_horizontal_only_conveyor()

func change_animation_if_falling(_s) -> void :
	animatedSprite.animation = "fall"

func _Interrupt() -> void :
	slashes = 0
	input_buffer = []
	var _fall_node = character.get_node("Fall")
	_fall_node.horizontal_velocity = horizontal_velocity
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
