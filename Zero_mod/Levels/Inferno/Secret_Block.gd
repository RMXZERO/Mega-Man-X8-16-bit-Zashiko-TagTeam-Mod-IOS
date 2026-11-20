extends KinematicBody2D

onready var blocking_wall: CollisionShape2D = $collisionShape2D
onready var animatedSprite: AnimatedSprite = $animatedSprite
onready var remains: Particles2D = $Remains / remains_particles
onready var remains_texture: Texture = preload("res://Zero_mod/Levels/Inferno/remains_Wall.png")

var unlocked: bool = false

func _ready() -> void :
	animatedSprite.animation = "Locked"

func _on_area2D_body_entered(body: Node) -> void :
	if not unlocked:
		if body.is_in_group("Player Projectile"):
			if "Juuhazan_Charged_B" in body.name:
				unlock_secret()
				unlocked = true
			elif "Juuhazan_Charged_C" in body.name:
				unlock_secret()
				unlocked = true
			elif "SqueezeBombCharged" in body.name:
				unlock_secret()
				unlocked = true
			elif "Player_Desperation" in body.name:
				unlock_secret()
				unlocked = true
		if body.name == "RideArmorPunch":
			unlock_secret()
			unlocked = true
		elif body.name == "NovaStrikeCharged":
			unlock_secret()
			unlocked = true
		elif body.name == "GigaCrashCharged":
			unlock_secret()
			unlocked = true
		elif body.name == "GenmuzeroCharged":
			unlock_secret()
			unlocked = true
		elif body.name == "Genmuzerowave":
			unlock_secret()
			unlocked = true
		elif body.name == "Player_Desperation":
			unlock_secret()
			unlocked = true

func unlock_secret() -> void :
	remains.texture = remains_texture
	remains.emitting = true
	blocking_wall.set_deferred("disabled", true)
	animatedSprite.animation = "Unlocked"
