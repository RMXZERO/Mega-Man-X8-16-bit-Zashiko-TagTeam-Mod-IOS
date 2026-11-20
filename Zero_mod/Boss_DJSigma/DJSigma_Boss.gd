extends Panda

onready var afterimages = get_node("animatedSprite").get_node("afterImages")
onready var afterimages2 = get_node("animatedSprite").get_node("afterImages2")
onready var sprite = get_node("animatedSprite")

onready var boss_ai = get_node("BossAI")

var only_x: bool = false
var only_zero: bool = false
var only_axl: bool = false
var virus_start: bool = false

func _ready() -> void :
	only_x = false
	only_zero = false
	only_axl = false
	virus_start = false
	
	if CharacterManager.player_character == "X":
		only_x = true
	elif CharacterManager.player_character == "Zero":
		only_zero = true
	elif CharacterManager.player_character == "Axl":
		only_axl = true
	else:
		only_zero = true
		
	end_vrius()

func dash_afterimages_on() -> void :
	afterimages.active = true
	afterimages.activate()

func dash_afterimages_off() -> void :
	afterimages.active = false
	afterimages.deactivate()

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

onready var virus_sprite = get_node("animatedSprite").get_node("VirusSprite")

onready var virus_sprite_1 = virus_sprite.get_node("VirusSprite")
onready var virus_sprite_2 = virus_sprite.get_node("VirusSprite2")
onready var virus_sprite_3 = virus_sprite.get_node("VirusSprite3")

var virus_1_deflect: float = 0
var virus_2_deflect: float = 0
var virus_3_deflect: float = 0
var deflect_1_timer: float = 0
var deflect_2_timer: float = 0
var deflect_3_timer: float = 0
var max_deflect_time: float = 12

func _process(delta: float) -> void:
	._process(delta)
	deflect_1_timer += delta
	deflect_2_timer += delta
	deflect_3_timer += delta
	if sprite.animation == "teleport_out_air" or \
	sprite.animation == "teleport_out_land" or \
	sprite.animation == "teleport_in_air" or \
	sprite.animation == "teleport_in_land" or \
	sprite.animation == "sigma_virus_fist_in" or \
	sprite.animation == "sigma_virus_fist_attack" or \
	sprite.animation == "sigma_virus_fist_out" or \
	sprite.animation == "empty" or \
	sprite.animation == "block_ready" or \
	sprite.animation == "block_loop":
		virus_sprite.visible = false
		virus_sprite_1.get_node("DamageOnTouch").deactivate()
		virus_sprite_2.get_node("DamageOnTouch").deactivate()
		virus_sprite_3.get_node("DamageOnTouch").deactivate()
	else:
		if boss_ai.used_desperation and virus_start:
			virus_sprite.visible = true
			if virus_1_deflect <= max_deflect_time:
				virus_sprite_1.get_node("DamageOnTouch").activate()
				virus_sprite_1.visible = true
			else:
				virus_sprite_1.get_node("DamageOnTouch").deactivate()
				virus_sprite_1.visible = false
				
			if virus_2_deflect <= max_deflect_time:
				virus_sprite_2.get_node("DamageOnTouch").activate()
				virus_sprite_2.visible = true
			else:
				virus_sprite_2.get_node("DamageOnTouch").deactivate()
				virus_sprite_2.visible = false
				
			if virus_3_deflect <= max_deflect_time:
				virus_sprite_3.get_node("DamageOnTouch").activate()
				virus_sprite_3.visible = true
			else:
				virus_sprite_3.get_node("DamageOnTouch").deactivate()
				virus_sprite_3.visible = false
				
			if virus_1_deflect > max_deflect_time and virus_2_deflect > max_deflect_time and virus_3_deflect > max_deflect_time and virus_start:
				virus_start = false
				end_vrius()
	
	if virus_sprite.visible and virus_start:
		virus_sprite.rotation_degrees = clamp(virus_sprite.rotation_degrees + delta * 180.0, -360.0, 360)
		virus_sprite_1.rotation_degrees = - virus_sprite.rotation_degrees
		virus_sprite_2.rotation_degrees = - virus_sprite.rotation_degrees
		virus_sprite_3.rotation_degrees = - virus_sprite.rotation_degrees
		if virus_sprite.rotation_degrees == 360:
			virus_sprite.rotation_degrees = -360


func end_vrius() -> void:
	virus_start = false
	virus_sprite.visible = false
	virus_sprite_1.visible = true
	virus_sprite_2.visible = true
	virus_sprite_3.visible = true
	virus_sprite.rotation_degrees = 0
	virus_sprite_1.rotation_degrees = 0
	virus_sprite_2.rotation_degrees = 0
	virus_sprite_3.rotation_degrees = 0
	virus_sprite_1.modulate = Color(1, 1, 1, 1)
	virus_sprite_2.modulate = Color(1, 1, 1, 1)
	virus_sprite_3.modulate = Color(1, 1, 1, 1)
	virus_1_deflect = 0
	virus_2_deflect = 0
	virus_3_deflect = 0
	virus_sprite_1.get_node("DamageOnTouch").deactivate()
	virus_sprite_2.get_node("DamageOnTouch").deactivate()
	virus_sprite_3.get_node("DamageOnTouch").deactivate()
	max_deflect_time = 12 + CharacterManager.game_mode * 2

onready var sfx_deflect: AudioStreamPlayer2D = get_node("deflect")

func _on_vrius_1_body_entered(body: Node) -> void :
	if virus_sprite.visible and virus_start and virus_sprite_1.visible:
		if body.is_in_group("Player Projectile"):
			deflect(body)
			if deflect_1_timer > 0.2:
				virus_1_deflect += 1
				deflect_1_timer = 0
				sfx_deflect.play()
				virus_sprite_1.modulate = Color(100, 100, 100, 1)
				yield(get_tree().create_timer(0.1), "timeout")
				virus_sprite_1.modulate = Color(1, 1, 1, 1)

func _on_vrius_2_body_entered(body: Node) -> void :
	if virus_sprite.visible and virus_start and virus_sprite_2.visible:
		if body.is_in_group("Player Projectile"):
			deflect(body)
			if deflect_2_timer > 0.2:
				virus_2_deflect += 1
				deflect_2_timer = 0
				sfx_deflect.play()
				virus_sprite_2.modulate = Color(100, 100, 100, 1)
				yield(get_tree().create_timer(0.1), "timeout")
				virus_sprite_2.modulate = Color(1, 1, 1, 1)

func _on_vrius_3_body_entered(body: Node) -> void :
	if virus_sprite.visible and virus_start and virus_sprite_3.visible:
		if body.is_in_group("Player Projectile"):
			deflect(body)
			if deflect_3_timer > 0.2:
				virus_3_deflect += 1
				deflect_3_timer = 0
				sfx_deflect.play()
				virus_sprite_3.modulate = Color(100, 100, 100, 1)
				yield(get_tree().create_timer(0.1), "timeout")
				virus_sprite_3.modulate = Color(1, 1, 1, 1)

func deflect(body: Node) -> void :
	for deflect in deflects:
		if String(deflect) in body.name:
			if body.has_method("destroy"):
				body.destroy()
			else:
				body.queue_free()


