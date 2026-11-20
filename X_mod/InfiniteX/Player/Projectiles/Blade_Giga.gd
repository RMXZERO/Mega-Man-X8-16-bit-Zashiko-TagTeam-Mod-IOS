extends SimplePlayerProjectile

const minimum_time_between_recharges: = 0.1

const bypass_shield: = true
const continuous_damage := true
const destroyer := true
var big_wave: bool = false
var mid_wave: bool = false
var mini_wave: bool = false

func _Update(delta: float) -> void :
	._Update(delta)
	if big_wave:
		if animatedSprite.frame >= 5:
			animatedSprite.frame = 4
	if mid_wave:
		if animatedSprite.frame >= 3:
			animatedSprite.frame = 2
	if mini_wave:
		if animatedSprite.frame >= 1:
			animatedSprite.frame = 0

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
