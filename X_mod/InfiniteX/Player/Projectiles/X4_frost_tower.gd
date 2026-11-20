extends SimplePlayerProjectile

const bypass_shield: = true

func _ready() -> void :
	Event.emit_signal("screenshake", 1)
	set_horizontal_speed(0)
	set_vertical_speed(0)

func _Update(delta: float) -> void :
	._Update(delta)
	set_horizontal_speed(0)
	if animatedSprite.frame <= 6:
		$collisionShape2D.set_deferred("disabled", true)
		$area2D/collisionShape2D.set_deferred("disabled", true)
	if animatedSprite.frame >= 7:
		set_vertical_speed(420)
		$collisionShape2D.set_deferred("disabled", false)
		$area2D/collisionShape2D.set_deferred("disabled", false)

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

