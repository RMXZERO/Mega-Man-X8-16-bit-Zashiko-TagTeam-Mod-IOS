extends GenericProjectile

const bypass_shield: = true

var can_deflect: bool = false
var go_up: bool = false
var next_speed: float = 400
var last_postion: Vector2

var deflects: Array = [
	"Axl Bullet", 
	"Copy Bullet", 
	"BlackArrow", 
	"BlastLauncher", 
	"BlastLaunchCharged", 
	"BoundBlaster", 
	"IceGattling",
	"RayGun",
	"SpiralMagnum",
	"Bike Lemon",
	"Lemon",
	"Medium",
	"CrystalBouncer",
	"DarkArrow",
	"DriftDiamond",
	"Aux Buster",
	"Charged Buster",
	"Triple Buster"
]

func _ready() -> void :
	$DamageOnTouch.activate()
	last_postion = global_position

func _Update(delta: float) -> void :
	._Update(delta)
	if animatedSprite.animation == "death_ball":
		crash_ball_position(delta)
		
	if animatedSprite.animation == "block_ready":
		if animatedSprite.frame < 24:
			$area2D/collisionShape2D.disabled = true
		elif animatedSprite.frame >= 24 and animatedSprite.frame <= 38:
			$area2D/collisionShape2D.disabled = false
		elif animatedSprite.frame >= 59:
			destroy()
		
	if can_deflect:
		can_deflect = false
		$collisionShape2D.set_deferred("disabled", false)
		
	if is_in_group("Enemy Projectile"):
		damage = $DamageOnTouch.damage
		damage_to_bosses = $DamageOnTouch.damage
		damage_to_weakness = $DamageOnTouch.damage
		
	if not is_in_group("Enemy Projectile"):
		$collisionShape2D.set_deferred("disabled", true)
		damage = 0
		damage_to_bosses = 0
		damage_to_weakness = 0

var max_ball_offset: float = 48
var ball_offset: float = 0

func crash_ball_position(delta: float) -> void :
	if max_ball_offset > 0:
		ball_offset -= delta * 10 * get_facing_direction()
	if go_up:
		global_position.y = last_postion.y - max_ball_offset * sin(ball_offset)
	else:
		global_position.y = last_postion.y + max_ball_offset * sin(ball_offset)

func _OnScreenExit() -> void :
	destroy()

func rotate_degrees(degrees : float) -> void:
	rotation_degrees = degrees

func _OnHit(_target_remaining_HP) -> void: #override
	pass

func deflect(_var) -> void :
	pass

func set_direction(new_direction) -> void :
	Log("Seting direction: " + str(new_direction))
	facing_direction = new_direction

func destroy() -> void :
	Log("Being Destroyed")
	emit_signal("projectile_end", self)
	queue_free()

func damage(damage, inflicter) -> float:
	return 0.1

func _on_area2D_body_entered(body: Node) -> void :
	if animatedSprite.animation == "death_ball":
		return
	if active:
		if body.is_in_group("Enemies") or body.is_in_group("Bosses") or body.is_in_group("Player"):
			return
		if body.is_in_group("Player Projectile"):
			for deflect in deflects:
				if String(deflect) in body.name:
					if body.has_method("hit"):
						body.hit(self)
					elif body.has_method("_OnHit"):
						body._OnHit(self)
					elif body.has_method("on_wall_hit"):
						body.on_wall_hit()
					elif body.has_method("destroy"):
						body.destroy()
					else:
						body.queue_free()
					if body.has_method("_OnHit"):
						body._OnHit(self)
					elif body.has_method("on_wall_hit"):
						body.on_wall_hit()
					elif body.has_method("destroy"):
						body.destroy()
					else:
						body.queue_free()
					if body.has_method("on_wall_hit"):
						body.on_wall_hit()
					elif body.has_method("destroy"):
						body.destroy()
					else:
						body.queue_free()
