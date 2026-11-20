extends SimplePlayerProjectile

const bypass_shield: = true
const continuous_damage := true
const destroyer := true

func _ready():
	$animatedSprite.visible = false
	$animatedSprite2.visible = false
	$animatedSprite3.visible = false

func _Update(delta: float) -> void :
	._Update(delta)
	if not CharacterManager.use_old_sprite:
		$animatedSprite.visible = true
	if CharacterManager.ultimate_x_armor and not CharacterManager.hide_x_armor:
		$animatedSprite2.visible = true
	if CharacterManager.ultimate_x_armor and not CharacterManager.infinite_x_activated and not CharacterManager.hide_x_armor:
		$animatedSprite2.visible = true
	if CharacterManager.ultimate_x_armor and CharacterManager.hide_x_armor:
		$animatedSprite3.visible = true
	if CharacterManager.infinite_x_activated and not CharacterManager.use_old_sprite:
		$animatedSprite3.visible = true

func rotate_degrees(degrees : float) -> void:
	rotation_degrees = degrees

func _OnHit(_target_remaining_HP) -> void:
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

