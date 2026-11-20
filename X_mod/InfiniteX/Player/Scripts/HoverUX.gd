extends DashJump

export  var upgraded: = false

onready var _hover_effect = character.get_node("animatedSprite").get_node("HoverEffect")
onready var animatedSprite: AnimatedSprite = character.get_node("animatedSprite")

export  var saber_hitbox: Resource = preload("res://X_mod/UltimateX/Player/NovaStrike/NovaStrike_Hitbox.tscn")
export  var damage: float = 4.0
export  var damage_boss: float = 4.0
export  var damage_weakness: float = 24.0
export  var hitbox_break_guards: bool = false

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

var max_air_jumps: = 1
var current_air_jumps: = 0
var vertical_velocity = 90
var should_end_walljump: = false
var should_end_dashwalljump: = false
var _hover
var emitted_hover: = false
var hover_damage = 0.5

func _ready() -> void :
	if active:
		character.listen("land", self, "reset_jump_count")
		character.listen("ride", self, "reset_jump_count")
		character.listen("wallslide", self, "reset_jump_count")
		character.listen("walljump", self, "reset_jump_count")
		character.listen("airdash", self, "reduce_air_jumps")
		character.listen("firedash", self, "reduce_air_jumps")

func set_max_air_jumps(value: int):
	max_air_jumps = value
	current_air_jumps = value
	Log("setting max airjumps:" + str(current_air_jumps))

func _Setup():
	character.add_invulnerability("Hover")
	animatedSprite.material.set_shader_param("Alpha", 1)
	set_horizontal_speed(0)
	set_vertical_speed(0)
	interrupt_if_needed()
	reduce_air_jumps(1)
	._Setup()

func emit_dashjump() -> void :
	pass

func reset_jump_count(_dummy: = null):
	current_air_jumps = max_air_jumps
	Log("resetting amount of airjumps:" + str(current_air_jumps))

func reduce_air_jumps(amount: = 1):
	Log("Reducing amount of airjumps by " + str(amount))
	current_air_jumps -= amount

func _StartCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation == "dodge":
		return false
	if character.ride_eject_delay > 0:
		return false
	if current_air_jumps <= 0:
		if not upgraded:
			return false
	if not character.is_on_floor():
		if character.time_since_on_floor > leeway_time:
			var walljump = character.get_executing_ability("WallJump")
			var dashwalljump = character.get_executing_ability("DashWallJump")
			if not walljump and not dashwalljump:
				reset_interrupt_bools()
				return true
			else:
				if walljump:
					if walljump.timer > 0.25:
						should_end_walljump = true
						return true
				if dashwalljump:
					if dashwalljump.timer > 0.25:
						should_end_dashwalljump = true
						return true
	return false

func start_hover_effect():
	if not emitted_hover:
		_hover_effect.visible = true
		_hover_effect.playing = true
		_hover_effect.frame = 0
		emitted_hover = true

func reset_hover_effect():
	if emitted_hover:
		_hover_effect.visible = false
		_hover_effect.playing = false
		emitted_hover = false

func play_hover_sound(_delta):
	if _hover_effect.frame == 0:
		$audioStreamPlayer2D.playing = true
	if _hover_effect.frame == 1:
		animatedSprite.position.y = clamp(animatedSprite.position.y + _delta * 32, -4, 0)
	if _hover_effect.frame == 2:
		animatedSprite.position.y = clamp(animatedSprite.position.y + _delta * 32, -4, 0)
	if _hover_effect.frame == 3:
		animatedSprite.position.y = clamp(animatedSprite.position.y - _delta * 32, -4, 0)
	if _hover_effect.frame == 4:
		animatedSprite.position.y = clamp(animatedSprite.position.y - _delta * 32, -4, 0)

func should_hover() -> bool:
	if not has_let_go_of_input:
		if not character.is_on_floor():
			if upgraded:
				return true
			if not Has_time_ran_out():
				return true
	return false

func _Update(_delta: float) -> void :
	hitbox_and_position()
	if character.get_action_just_pressed("jump") and emitted_hover:
		has_let_go_of_input = true
	
	if should_hover():
		start_hover_effect()
		play_hover_sound(_delta)
		zero_bonus_horizontal_speed()
		if character.is_shooting:
			set_movement_and_direction(0)
			character.set_vertical_speed(0)
		else:
			if character.get_animation() != "hover":
				character.play_animation("hover")
			if Input.is_action_pressed("move_up"):
				character.set_vertical_speed( - vertical_velocity)
				if get_facing_direction() > 0:
					animatedSprite.rotation_degrees = -45
				else:
					animatedSprite.rotation_degrees = 45
			elif Input.is_action_pressed("move_down"):
				character.set_vertical_speed(vertical_velocity)
				if get_facing_direction() > 0:
					animatedSprite.rotation_degrees = 45
				else:
					animatedSprite.rotation_degrees = -45
			else:
				character.set_vertical_speed(0)
				animatedSprite.rotation_degrees = 0

			if Input.is_action_pressed("move_left"):
				set_direction_as_pressed_direction()
				character.set_horizontal_speed( - horizontal_velocity)
			elif Input.is_action_pressed("move_right"):
				set_direction_as_pressed_direction()
				character.set_horizontal_speed(horizontal_velocity)
			else:
				character.set_horizontal_speed(0)

	else:
		reset_hover_effect()
		change_animation_if_falling("fall")
		set_movement_and_direction(horizontal_velocity)
		process_gravity(_delta)

func reset_interrupt_bools():
	should_end_walljump = false
	should_end_dashwalljump = false

func interrupt_if_needed():
	if should_end_walljump:
		interrupt("WallJump")
	elif should_end_dashwalljump:
		interrupt("DashWallJump")
	reset_interrupt_bools()
	reset_hover_effect()

func interrupt(ability: String):
	Log("Ending " + ability)
	character.force_end(ability)
	reset_hover_effect()

func _Interrupt() -> void :
	character.remove_invulnerability("Hover")
	character.dashfall = false
	animatedSprite.rotation_degrees = 0
	animatedSprite.position.y = -4
	$audioStreamPlayer2D.playing = false
	._Interrupt()
	reset_hover_effect()
	if is_instance_valid(current_hitbox):
		current_hitbox.queue_free()

func check_for_let_go_of_input():
	pass
	#if input == 0:
	#	has_let_go_of_input = true

func _ResetCondition() -> bool:
	return false

func change_animation_if_falling(_s) -> void :
	if not changed_animation:
		if character.get_animation() != "fall":
			if character.get_vertical_speed() > 0:
				EndAbility()

func Has_time_ran_out() -> bool:
	return max_jump_time < timer

func _EndCondition() -> bool:
	if Has_time_ran_out() and not upgraded:
		reset_hover_effect()
		return true
	if character.is_on_floor():
		reset_hover_effect()
		return true
	return false

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
	current_hitbox.name = "Aux Buster"
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
	hitbox_damage = hover_damage
	hitbox_damage_boss = hover_damage
	hitbox_damage_weakness = hover_damage
	hitbox_break_guards = true
	hitbox_rehit_time = 0.1
	if animatedSprite.frame >= 0 and animatedSprite.frame < 3:
		hitbox_upleft = Vector2( -22, - 11)
		hitbox_downright = Vector2(20, 16)
		spawn_hitbox(hitbox_upleft, hitbox_downright)
	reset_hitbox()

