extends SimplePlayerProjectile
var tracking: bool = false

var track_timer: = 0.0
export  var tracking_time: = 0.1
const minimum_time_between_recharges: = 0.1

const bypass_shield: = true
const continuous_damage := true
const destroyer := true

func _Update(delta: float) -> void :
	._Update(delta)
	CharacterManager.set_zeroX8_colors(animatedSprite)
	track()

func track():
	set_horizontal_speed(600 * get_facing_direction())
	set_rotation(Vector2(get_horizontal_speed(), get_vertical_speed()).angle())
	if facing_direction == - 1:
		scale.y=-1
	else:
		scale.y=1

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
