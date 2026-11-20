extends BossWeaponAxl

const max_bounces: int = 3
const destroyer: bool = true

export  var explosion: PackedScene

var last_speed: Vector2
var bounces: int = 0
var last_bounce: float = 0.0
var ending: bool = false
var timer: float = 0.0
var creator: Node2D
onready var tween = TweenController.new(self, false)

func hit(target) -> void :
	if active:
		active = false
		target.damage(damage, self)
		explode()
		disable_projectile_visual()
		remove_from_group("Player Projectile")

func leave(_target) -> void :
	pass

func deflect(_body) -> void :
	explode()

func launch_setup(_direction, _launcher_velocity: float = 0.0) -> void :
	var _initial_speed: = 0.0
	if is_instance_valid(creator):
		_initial_speed = creator.get_horizontal_speed()
	var max_x_speed = horizontal_velocity
	var max_y_speed = vertical_velocity
	tween.method("set_horizontal_speed", 0.0, max_x_speed, 1.75)
	tween.method("set_vertical_speed", 0.0, max_y_speed, 1.75)
	set_rotation(Vector2(get_horizontal_speed(), get_vertical_speed()).angle())

func disable_damage() -> void :
	$collisionShape2D.set_deferred("disabled",true)

func _physics_process(_delta: float) -> void :
	if not ending:
		if has_hit_scenery():
			explode()
		if is_on_floor() or is_on_wall():
			explode()
	if ending:
		destroy()

	update_traveled_distance()

var last_position: = Vector2.ZERO
func update_traveled_distance() -> void :
	last_position = global_position

func explode() -> void :
	set_vertical_speed(0)
	set_horizontal_speed(0)
	instantiate(explosion)
	disable_visuals()
	particle_visual.emitting = false
	ending = true

func instantiate(scene: PackedScene) -> Node2D:
	var instance = scene.instance()
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(global_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())
	return instance
