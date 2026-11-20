extends GenericProjectile

const bypass_shield: = true
export  var mini_projectile: PackedScene
var can_deflect: bool = false
var destroy: Array = [
	"GenmuzeroCharged", 
	"Genmuzerowave", 
	"Juuhazan", 
	"Juuhazan_Charged_A", 
	"Juuhazan_Charged_B", 
	"SqueezeBombCharged", 
	"Youdantotsu"
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

func _Update(delta: float) -> void :
	._Update(delta)
	if animatedSprite.animation == "frost_tower":
		if animatedSprite.frame >= 7:
			set_vertical_speed(420)
			$collisionShape2D.set_deferred("disabled", false)
			$area2D/collisionShape2D.set_deferred("disabled", false)
			$DamageOnTouch/area2D/collisionShape2D.set_deferred("disabled", false)
		
	if can_deflect:
		can_deflect = false
		$collisionShape2D.set_deferred("disabled", false)
		
	if animatedSprite.animation == "ball_loop":
		if timer > 2:
			destroy()
		
	if animatedSprite.animation == "soul_body":
		set_rotation(Vector2(get_horizontal_speed(), get_vertical_speed()).angle())
		
	if is_in_group("Enemy Projectile"):
		damage = $DamageOnTouch.damage
		damage_to_bosses = $DamageOnTouch.damage
		damage_to_weakness = $DamageOnTouch.damage
		
	if not is_in_group("Enemy Projectile"):
		$collisionShape2D.set_deferred("disabled", true)
		damage = 0
		damage_to_bosses = 0
		damage_to_weakness = 0

func _OnScreenExit() -> void :
	destroy()

func rotate_degrees(degrees : float) -> void:
	rotation_degrees = degrees

func create_mini_projectile():
	if mini_projectile:
		var projectile = mini_projectile.instance()
		get_tree().current_scene.add_child(projectile, true)
		projectile.set_global_position(global_position)
		projectile.set_creator(creator)
		projectile.initialize(facing_direction)

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
