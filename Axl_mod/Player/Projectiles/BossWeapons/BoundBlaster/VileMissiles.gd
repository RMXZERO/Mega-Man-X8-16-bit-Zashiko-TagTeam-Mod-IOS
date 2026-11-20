extends BossWeaponAxl

onready var start_particle: = get_node("Start Particle")
onready var tracker: Area2D = $animatedSprite/tracker
var speed := 170
export var tracker_update_interval := 0.1
export var transform_time := 1.5
var last_dir := Vector2(0,0)
var emitted := false
onready var hitparticle: Sprite = $"Hit Particle"

var hit_time: float = 0.0
var emitted_start_particle: bool = false
var ending: bool = false
var timer: float = 0.0
var attack_stage: int = 0
var first_stage: bool = false
var second_stage: bool = false

func _ready() -> void :
	._ready()

func _physics_process(delta: float) -> void :
	
	if attack_stage == 0:
		var target = get_target_from_facing_direction_first()
		if target:
			var dir: = Tools.get_angle_between(target, self)
			var target_speed = Vector2(speed * dir.x,speed * dir.y)
			slowly_turn_towards_target(target_speed)
			set_rotation(Vector2(get_horizontal_speed(),get_vertical_speed()).angle())
			if not first_stage:
				Tools.timer(0.5, "next_attack_stage", self)
				first_stage = true

	elif attack_stage == 1:
		animatedSprite.animation = "transform"
		set_horizontal_speed(last_dir.x * speed/4)
		set_vertical_speed(last_dir.y * speed/4)
		if not second_stage:
			Tools.timer(0.25, "next_attack_stage", self)
			second_stage = true

	elif attack_stage == 2:
		animatedSprite.animation = "speed"
		set_horizontal_speed(last_dir.x * speed * 4)
		set_vertical_speed(last_dir.y * speed * 4)
		Tools.timer(0.25, "next_attack_stage", self)
	
	if active:
		if has_hit_scenery():
			on_wall_hit()
			return
	else:
		timer += delta
		if timer > 0.2:
			destroy()
		return
	._physics_process(delta)

func next_attack_stage() -> void :
	attack_stage += 1

func get_target_from_facing_direction_first() -> Node2D:
	var first_check
	first_check = tracker
	var target = first_check.get_closest_target()
	return target

func slowly_turn_towards_target(target_speed : Vector2) -> void:
	var current_speed = Vector2(get_horizontal_speed(),get_vertical_speed())
	var current_angle = current_speed.normalized().angle()
	var target_angle = target_speed.normalized().angle()
	var new_angle = lerp_angle(current_angle,target_angle, tracker_update_interval)
	var new_speed = angle_to_vector2(new_angle)
	
	set_horizontal_speed(new_speed.x * speed)
	set_vertical_speed(new_speed.y * speed)
	last_dir = new_speed

func angle_to_vector2 (angle) -> Vector2:
	return Vector2(cos(angle), sin(angle))

func on_wall_hit() -> void :
	emit_hit_particle()
	animatedSprite.visible = false
	stop()
	disable_damage()
	deactivate()

func deactivate() -> void :
	active = false
	disable_projectile_visual()
	call_deferred("disable_damage")
	remove_from_group("Player Projectile")

func references_setup(direction) -> void :
	set_direction(direction)
	animatedSprite.scale.x = direction
	update_facing_direction()
	$animatedSprite.set_frame(int(rand_range(0, 2)))
	original_pitch = audio.pitch_scale

func process_hittime(delta: float) -> void :
	if hit_time > 0:
		hit_time += delta
	if hit_time > time_outside_screen / 3:
		disable_particle_visual()

func hit(target) -> void :
	if active:
		hit_time = 0.01
		countdown_to_destruction = 0.01
		target.damage(damage, self)
		emit_hit_particle()
		disable_projectile_visual()
		call_deferred("disable_damage")
		remove_from_group("Player Projectile")
		active = false

func emit_hit_particle() -> void :
	if not emitted_hit_particle:
		hit_particle.emit()
		emitted_hit_particle = true

func leave(_target) -> void :
	pass

func deflect(_body) -> void :
	.deflect(_body)
	$deflect_particle.emit()

func launch_setup(_direction, _launcher_velocity: float = 0.0) -> void :
	attack_stage = 0
	first_stage = false
	second_stage = false
	animatedSprite.animation = "normal"
	if get_facing_direction() > 0:
		get_node("animatedSprite").rotation = deg2rad(0)
	else:
		get_node("animatedSprite").rotation = deg2rad(180)
	animatedSprite.scale.x = get_facing_direction()
	animatedSprite.scale.y = get_facing_direction()
	set_horizontal_speed(horizontal_velocity)
	set_vertical_speed(vertical_velocity)
	set_rotation(Vector2(get_horizontal_speed(), get_vertical_speed()).angle())
	emit_start_particle()

func emit_start_particle() -> void :
	if not emitted_start_particle:
		start_particle.global_position = global_position
		start_particle.emit()
		emitted_start_particle = true

func disable_damage() -> void :
	$collisionShape2D.disabled = true
