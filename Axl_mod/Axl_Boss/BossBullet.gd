extends GenericProjectile

onready var start_particle: = get_node("Start Particle")
onready var hit_particle: = get_node("Hit Particle")
var emitted := false
var emitted_start_particle: bool = false
var blue_bullet: bool = false

func _ready() -> void :
	$DamageOnTouch.activate()

func _Update(delta: float) -> void :
	._Update(delta)
	emit_start_particle()
	if is_on_floor() or is_on_wall() or is_on_ceiling():
		on_wall_hit()

	if is_in_group("Enemy Projectile"):
		damage = $DamageOnTouch.damage
		damage_to_bosses = $DamageOnTouch.damage
		damage_to_weakness = $DamageOnTouch.damage

func rotate_degrees(degrees : float) -> void:
	rotation_degrees = degrees

func _OnHit(_target_remaining_HP) -> void: #override
	on_wall_hit()

func deflect(_var) -> void :
	pass

func set_direction(new_direction) -> void :
	Log("Seting direction: " + str(new_direction))
	facing_direction = new_direction

func destroy() -> void :
	Log("Being Destroyed")
	emit_signal("projectile_end", self)
	queue_free()

func emit_start_particle() -> void :
	if not emitted_start_particle:
		start_particle.global_position = global_position
		start_particle.emit()
		emitted_start_particle = true

func on_wall_hit() -> void :
	emit_hit_particle()

func emit_hit_particle() -> void :
	$collisionShape2D.disabled = true
	if not emitted:
		hit_particle.global_position = global_position
		hit_particle.emit(1)
		emitted = true
		destroy()
