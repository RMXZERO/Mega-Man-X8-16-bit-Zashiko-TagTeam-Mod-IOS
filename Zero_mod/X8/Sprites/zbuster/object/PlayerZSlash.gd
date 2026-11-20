extends SimplePlayerProjectile

const bypass_shield: = true
const continuous_damage := true
const destroyer := true

var activated: bool = false

func _ready() -> void :
	add_to_group("Player Projectile")
	animatedSprite.frame = 0
	animatedSprite.playing = true
	$animatedSprite2.frame = 0
	$animatedSprite2.playing = true
	randomize()
	var chance = randf() * 100
	if is_between(chance, 0, 20):
		animatedSprite.animation = "d1"
	elif is_between(chance, 20, 40):
		animatedSprite.animation = "d2"
	elif is_between(chance, 40, 60):
		animatedSprite.animation = "d3"
	elif is_between(chance, 60, 80):
		animatedSprite.animation = "d4"
	
	if chance >= 10:
		animatedSprite.flip_h = true
		if chance >= 75:
			animatedSprite.flip_v = true
	else:
		animatedSprite.flip_v = true
		if chance <= 25:
			animatedSprite.flip_h = true

	var offset_x = randf() * 32
	var offset_y = randf() * 32
	var positive_x = randi() %2
	var positive_y = randi() %2
	if positive_x >= 1:
		offset_x *= - 1
	if positive_y >= 1:
		offset_y *= - 1
	animatedSprite.offset = Vector2(offset_x, offset_y)

	Tools.timer(0.55, "queue_free", self)

func hide() -> void :
	$animatedSprite2.hide()
	Tools.timer(0.35, "play_sound", self)

func rotate_degrees(degrees : float) -> void:
	rotation_degrees = degrees

func play_sound() -> void :
	$cut.play()

func is_between(c, _min, _max) -> bool:
	return c > _min and c <= _max

func _OnHit(_target_remaining_HP) -> void :
	pass

func deflect(_var) -> void :
	pass

func _Update(_delta: float) -> void :
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
