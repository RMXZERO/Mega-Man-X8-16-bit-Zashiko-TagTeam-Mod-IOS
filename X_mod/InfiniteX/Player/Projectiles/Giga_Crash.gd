extends SimplePlayerProjectile

const minimum_time_between_recharges: = 0.1

const bypass_shield: = true
const continuous_damage := true
const destroyer := true

var switch: bool = false
var switch_2: bool = false

var hitbox_rehit_time = 2.0

func reset_hitbox():
	hitbox_rehit_time = 2.0

func _ready() -> void :
	scale.x = 70
	scale.y = 10
	Tools.timer(1.5, "can_switch", self)
	Tools.timer(1.7, "can_switch_2", self)
	Event.listen("character_switch", self, "destroy")

func can_switch() -> void :
	switch = true

func can_switch_2() -> void :
	switch_2 = true

func _Update(delta: float) -> void :
	._Update(delta)
	if animatedSprite.animation == "start":
		$collisionShape2D.set_deferred("disabled", true)
		$area2D/collisionShape2D.set_deferred("disabled", true)
		scale.x = clamp(scale.x - delta * 50.0, 1, 70)
		if scale.x <= 1:
			scale.x = 1
			animatedSprite.animation = "black"
	if animatedSprite.animation == "black":
		$collisionShape2D.set_deferred("disabled", true)
		$area2D/collisionShape2D.set_deferred("disabled", true)
		scale.x = 1
		if switch:
			animatedSprite.animation = "boom_2"
	if animatedSprite.animation == "boom_2":
		set_horizontal_speed(0)
		$collisionShape2D.set_deferred("disabled", false)
		$area2D/collisionShape2D.set_deferred("disabled", false)
		scale.x = clamp(scale.x + delta * 100.0, 1, 70)
		if switch_2:
			$animatedSprite/animatedSprite.animation = "boom_2"
			$animatedSprite/animatedSprite2.animation = "boom_2"
			animatedSprite.animation = "boom"
			scale.x = 1
	if animatedSprite.animation == "boom":
		scale.x = clamp(scale.x + delta * 200.0, 1, 70)
		if scale.x >= 70:
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
