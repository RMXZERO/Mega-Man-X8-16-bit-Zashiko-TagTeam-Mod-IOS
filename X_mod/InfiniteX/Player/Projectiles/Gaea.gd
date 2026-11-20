extends SimplePlayerProjectile

const minimum_time_between_recharges: = 0.1

const bypass_shield: = true
const continuous_damage := true
const destroyer := true

var hitbox_rehit_time = 0.1

func reset_hitbox():
	hitbox_rehit_time = 0.1

func _ready() -> void :
	Event.listen("character_switch", self, "destroy")

func _Update(delta: float) -> void :
	._Update(delta)
	if animatedSprite.frame <= 25:
		$collisionShape2D.set_deferred("disabled", true)
	if animatedSprite.frame >= 26 and animatedSprite.frame <= 65:
		$collisionShape2D.set_deferred("disabled", false)
	if animatedSprite.frame >= 66:
		$collisionShape2D.set_deferred("disabled", true)
		destroy()

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
