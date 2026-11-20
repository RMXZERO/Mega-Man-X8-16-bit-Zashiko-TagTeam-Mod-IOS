extends GenericProjectile

const bypass_shield: = true

onready var crash_beam_1 = get_node("oz_crash_beam")
onready var crash_beam_2 = get_node("oz_crash_beam2")
onready var crash_beam_3 = get_node("oz_crash_beam3")
onready var crash_beam_4 = get_node("oz_crash_beam4")
onready var crash_beam_5 = get_node("oz_crash_beam5")

var beam_start: float = 0
var beam_1_offset: float = 0
var beam_2_offset: float = 1.57
var beam_3_offset: float = 3.14
var beam_4_offset: float = 3.925
var beam_5_offset: float = 5.495

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
	animatedSprite.visible = false
	crash_beam_1.visible = false
	crash_beam_2.visible = false
	crash_beam_3.visible = false
	crash_beam_4.visible = false
	crash_beam_5.visible = false
	$DamageOnTouch.activate()
	$area2D/collisionShape2D.disabled = true
	attack_stage = 1

func _Update(delta: float) -> void :
	._Update(delta)
	if is_in_group("Enemy Projectile"):
		damage = $DamageOnTouch.damage
		damage_to_bosses = $DamageOnTouch.damage
		damage_to_weakness = $DamageOnTouch.damage
	
	if active:
		beam_start += delta
		beam_1_offset += delta * 1 * 10
		beam_2_offset += delta * 1 * 10
		beam_3_offset += delta * 1 * 10
		beam_4_offset += delta * 1 * 10
		beam_5_offset += delta * 1 * 10
		
	if attack_stage == 1:
		animatedSprite.visible = false
		animatedSprite.animation = "omega_crash_beam"
		animatedSprite.frame = 0
		animatedSprite.playing = true
		crash_beam_1.visible = true
		crash_beam_2.visible = true
		crash_beam_3.visible = true
		crash_beam_4.visible = true
		crash_beam_5.visible = true
		next_attack_stage()
		
	elif attack_stage == 2:
		if animatedSprite.animation == "omega_crash_beam" and animatedSprite.frame >= 3:
			$area2D/collisionShape2D.disabled = false
			animatedSprite.animation = "omega_crash_beam_loop"
			next_attack_stage()
		
	elif attack_stage == 3:
		if animatedSprite.animation == "omega_crash_beam_loop":
			crash_beam_1.position.x = 0 + 32 * sin(beam_1_offset)
			crash_beam_2.position.x = 0 + 32 * sin(beam_2_offset)
			crash_beam_3.position.x = 0 + 32 * sin(beam_3_offset)
			crash_beam_4.position.x = 0 + 32 * sin(beam_4_offset)
			crash_beam_5.position.x = 0 + 32 * sin(beam_5_offset)
			if beam_start > 1.2:
				next_attack_stage()
		
	elif attack_stage == 4:
		animatedSprite.animation = "omega_crash_beam_end"
		next_attack_stage()
		
	elif attack_stage == 5:
		if animatedSprite.animation == "omega_crash_beam_end" and animatedSprite.frame >= 3:
			destroy()

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
