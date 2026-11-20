extends GenericProjectile

const bypass_shield: = true

var only_zero: bool = false
var can_deflect: bool = false
var destroy: Array = [
	"GenmuzeroCharged", 
	"Genmuzerowave", 
	"SqueezeBombCharged", 
]

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
	"DriftDiamond"
]

func _ready() -> void :
	$DamageOnTouch.activate()
	damage = $DamageOnTouch.damage
	damage_to_bosses = $DamageOnTouch.damage
	damage_to_weakness = $DamageOnTouch.damage
	CharacterManager.set_axl_normal_colors(animatedSprite)

func _Update(delta: float) -> void :
	._Update(delta)
	if only_zero:
		animatedSprite.animation = "agile_wave_2"
		
	if can_deflect:
		can_deflect = false
		$collisionShape2D.set_deferred("disabled", false)
		
	if not is_in_group("Enemy Projectile"):
		$collisionShape2D.set_deferred("disabled", true)
		damage = 0
		damage_to_bosses = 0
		damage_to_weakness = 0

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



