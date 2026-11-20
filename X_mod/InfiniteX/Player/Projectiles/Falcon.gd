extends SimplePlayerProjectile

const minimum_time_between_recharges: = 0.1

const bypass_shield: = true
const continuous_damage := true
const destroyer := true
var camera_position: Vector2
var gigaattack: bool = false
var candestroy: bool = false

func _ready() -> void :
	camera_position = GameManager.camera.get_camera_screen_center()
	Tools.timer(5.0, "can_destroy", self)
	if gigaattack:
		position.x += 0 + rand_range( - 400, 400)

func can_destroy() -> void :
	candestroy = true

func _OnScreenExit() -> void :
	if gigaattack:
		#position.x += 0 + rand_range( - 400, 400)
		if position.x > camera_position.x:
			position.x += -400
		elif position.x < camera_position.x:
			position.x += 400
	if not candestroy:
		yield(get_tree().create_timer(0.1), "timeout")
		candestroy = true
	if candestroy:
		destroy()

func _Update(delta: float) -> void :
	._Update(delta)

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
