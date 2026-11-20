extends SimplePlayerProjectile

const minimum_time_between_recharges: = 0.1

const bypass_shield: = true
const continuous_damage := true
const destroyer := true

var up_giga: bool = false
var down_giga: bool = false
var face: int = 1

var hitbox_rehit_time = 1.0

func reset_hitbox():
	hitbox_rehit_time = 1.0

func _ready() -> void :
	Tools.timer(3, "destroy", self)
	Event.listen("character_switch", self, "destroy")

func _Update(delta: float) -> void :
	._Update(delta)
	timer += delta
	var max_rotation_degrees = 360
	if down_giga:
		rotation_degrees = clamp(rotation_degrees + delta * 360.0, -360.0, max_rotation_degrees)
		if face < 0:
			animatedSprite.rotation_degrees = clamp(animatedSprite.rotation_degrees + delta * 720.0, -360.0, max_rotation_degrees)
		if face > 0:
			animatedSprite.rotation_degrees = clamp(animatedSprite.rotation_degrees - delta * 720.0, -360.0, max_rotation_degrees)
	elif up_giga:
		rotation_degrees = clamp(rotation_degrees - delta * 360.0, -360.0, max_rotation_degrees)
		if face < 0:
			animatedSprite.rotation_degrees = clamp(animatedSprite.rotation_degrees + delta * 720.0, -360.0, max_rotation_degrees)
		if face > 0:
			animatedSprite.rotation_degrees = clamp(animatedSprite.rotation_degrees - delta * 720.0, -360.0, max_rotation_degrees)
	
	if animatedSprite.rotation_degrees == -360 * face:
		animatedSprite.rotation_degrees = 360 * face
	
	if animatedSprite.frame >= 7:
		animatedSprite.frame = 3

func _OnHit(_target_remaining_HP) -> void :
	pass

func deflect(_var) -> void :
	pass

func set_direction(new_direction) -> void :
	Log("Seting direction: " + str(new_direction))
	facing_direction = new_direction

func _on_area2D_body_entered(body: Node) -> void :
	if active:
		if body.is_in_group("Enemies") or body.is_in_group("Bosses"):
			return
		if body.active:
			react(body)

func react(body: Node) -> void :
	call_deferred("deflect_projectile", body)

func deflect_projectile(body):
	if body.is_in_group("Enemy Projectile"):
		if body.has_method("_OnHit"):
			body._OnHit(self)
			return
		body.destroy()
