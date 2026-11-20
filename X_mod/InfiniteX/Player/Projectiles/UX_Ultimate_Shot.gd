extends ChargedBuster

export  var continue_shot: PackedScene = preload("res://X_mod/UltimateX/Player/Projectiles/Ultimate_Continue.tscn")

onready var sprite: AnimatedSprite = $animatedSprite
onready var particles: Particles2D = $particles2D
onready var collision_shape: CollisionShape2D = $collisionShape2D
onready var ray: RayCast2D = $rayCast2D

export var auxiliary_projectiles : PackedScene
export var charge2_projectiles : PackedScene

func projectile_setup(dir : int, position : Vector2, _launcher_velocity := 0.0):
	.projectile_setup(dir, position)
	call_deferred("create_auxiliary_shots",dir)

func create_auxiliary_shots(dir) -> void:
	var aux_shot = auxiliary_projectiles.instance()
	var aux_shot2 = auxiliary_projectiles.instance()
	var aux_shot3 = charge2_projectiles.instance()
	var aux_shot4 = charge2_projectiles.instance()
	get_tree().root.add_child(aux_shot,true)
	get_tree().root.add_child(aux_shot2,true)
	get_tree().root.add_child(aux_shot3,true)
	get_tree().root.add_child(aux_shot4,true)
	aux_shot.global_position = global_position
	aux_shot2.global_position = global_position
	aux_shot3.global_position = global_position
	aux_shot4.global_position = global_position

	var aux_velocity = horizontal_velocity
	aux_shot.go_up(aux_velocity)
	aux_shot2.go_down(aux_velocity)
	aux_shot3.go_up(aux_velocity)
	aux_shot4.go_down(aux_velocity)
	if dir > 0:
		aux_shot.go_right(aux_velocity)
		aux_shot2.go_right(aux_velocity)
		aux_shot3.go_right(aux_velocity)
		aux_shot4.go_right(aux_velocity)
	else:
		aux_shot.go_left(aux_velocity)
		aux_shot2.go_left(aux_velocity)
		aux_shot3.go_left(aux_velocity)
		aux_shot4.go_left(aux_velocity)
	aux_shot.update_facing_direction()
	aux_shot2.update_facing_direction()
	aux_shot3.update_facing_direction()
	aux_shot4.update_facing_direction()

func _physics_process(_delta: float) -> void :
	pass

func references_setup(direction) -> void :
	set_direction(direction)
	animatedSprite.scale.x = direction
	$particles2D.scale.x = direction
	update_facing_direction()
	$animatedSprite.set_frame(int(rand_range(0, 8)))
	original_pitch = audio.pitch_scale

func process_hittime(_delta: float) -> void :
	pass

func hit(target) -> void :
	target.damage(damage, self)
	spawn_damage_ball(target, true)

func spawn_damage_ball(target, _add_target):
	var damage_ball = continue_shot.instance()
	var hit_position = collision_shape.global_position + ((target.global_position - collision_shape.global_position) / 2)
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", damage_ball, true)
	damage_ball.set_global_position(hit_position)
	damage_ball.call_deferred("initialize", get_facing_direction())

func leave(_target) -> void :
	pass

func deflect(_body) -> void :
	spawn_damage_ball(_body, false)

func launch_setup(direction: int, _launcher_velocity: float = 0.0) -> void :
	set_horizontal_speed(horizontal_velocity * direction)

func disable_damage() -> void :
	pass

func go_up(speed) -> void :
	set_vertical_speed( - speed / 2)
func go_down(speed) -> void :
	set_vertical_speed(speed / 2)
func go_right(speed) -> void :
	set_horizontal_speed(speed / 2)
func go_left(speed) -> void :
	set_horizontal_speed( - speed / 2)

func update_facing_direction() -> void :
	if animatedSprite.visible:
		if direction.x < 0:
			facing_right = false;
		elif direction.x > 0:
			facing_right = true;
		if get_vertical_speed() < 0 and get_horizontal_speed() > 0:
			rotation_degrees = - 45.0
			particles.rotation_degrees = - 45.0
		elif get_vertical_speed() < 0 and get_horizontal_speed() < 0:
			rotation_degrees = - 135.0
			particles.rotation_degrees = - 135.0
		elif get_vertical_speed() > 0 and get_horizontal_speed() > 0:
			rotation_degrees = 45.0
			particles.rotation_degrees = 45.0
		elif get_vertical_speed() > 0 and get_horizontal_speed() < 0:
			rotation_degrees = 135.0
			particles.rotation_degrees = 135.0
	pass
