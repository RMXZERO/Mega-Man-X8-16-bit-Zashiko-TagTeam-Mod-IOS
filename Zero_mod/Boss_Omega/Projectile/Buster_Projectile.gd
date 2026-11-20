extends GenericProjectile

const bypass_shield: = true

var can_deflect: bool = false
var first_signal: bool = false
var next_speed: float = 400

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

	if is_on_floor():
		on_land_hit()

func on_land_hit() -> void :
	if not first_signal and animatedSprite.animation == "stone":
		first_signal = true
		animatedSprite.visible = false
		$DamageOnTouch.deactivate()
		Tools.timer(1.0, "destroy", self)
		var stone_particles = get_node_or_null("stone_particles")
		if stone_particles:
			stone_particles.emitting = true
		var break_sound = get_node_or_null("break_sound")
		if break_sound:
			break_sound.play()

func _OnScreenExit() -> void :
	if not first_signal and animatedSprite.animation == "shingetsurin":
		first_signal = true
		pause_shingetsurin()
	else:
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

func pause_shingetsurin() -> void :
	visibility.scale.x = 100
	visibility.scale.y = 20
	visibility.position.x = 0
	set_horizontal_speed(0)
	set_vertical_speed(0)
	$DamageOnTouch.hit_through_invulnerability = false
	Tools.timer(1.5, "set_next_speed", self)

func set_next_speed() -> void :
	$DamageOnTouch.hit_through_invulnerability = true
	var target_dir = get_player_angle(global_position)
	set_horizontal_speed(next_speed * target_dir.x)
	set_vertical_speed(next_speed * target_dir.y)

func get_player_angle(global_position : Vector2) -> Vector2:
	var speed = clamp(GameManager.player.get_horizontal_speed(),-30,30)
	var player_pos = GameManager.get_player_position() + Vector2(speed,-5)
	
	return ((player_pos) - global_position).normalized()

func _on_area2D_body_entered(body: Node) -> void :
	if active:
		if animatedSprite.animation == "shingetsurin":
			if body.is_in_group("Player"):
				if not first_signal:
					first_signal = true
					pause_shingetsurin()
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
