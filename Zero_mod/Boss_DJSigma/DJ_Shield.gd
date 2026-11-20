extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")

onready var damage: Node2D = $"../Damage"

onready var main = get_parent()
onready var sfx_slide: AudioStreamPlayer = get_parent().get_node("slide")
onready var sfx_dj_ball: AudioStreamPlayer = get_parent().get_node("dj_ball")
onready var sfx_dj_crash: AudioStreamPlayer = get_parent().get_node("dj_crash")
onready var sfx_dj_dash: AudioStreamPlayer = get_parent().get_node("dj_dash")
onready var sfx_dj_teleport: AudioStreamPlayer = get_parent().get_node("dj_teleport")
onready var sfx_dj_virus: AudioStreamPlayer = get_parent().get_node("dj_virus")
onready var sfx_dj_wave: AudioStreamPlayer = get_parent().get_node("dj_wave")
onready var sfx_dj_block: AudioStreamPlayer = get_parent().get_node("dj_block")
onready var sfx_dj_block_hit: AudioStreamPlayer = get_parent().get_node("dj_block_hit")
onready var sfx_sigma_intro: AudioStreamPlayer = get_parent().get_node("sigma_intro")
onready var sfx_sigma_easy: AudioStreamPlayer = get_parent().get_node("sigma_easy")
onready var sfx_sigma_throw: AudioStreamPlayer = get_parent().get_node("sigma_throw")
onready var sfx_sigma_kelei: AudioStreamPlayer = get_parent().get_node("sigma_kelei")
onready var sfx_sigma_lauch: AudioStreamPlayer = get_parent().get_node("sigma_lauch")
onready var sfx_sigma_lauch2: AudioStreamPlayer = get_parent().get_node("sigma_lauch2")
onready var sfx_sigma_lauch3: AudioStreamPlayer = get_parent().get_node("sigma_lauch3")
onready var sfx_sigma_owld: AudioStreamPlayer = get_parent().get_node("sigma_owld")
onready var sfx_sigma_muda: AudioStreamPlayer = get_parent().get_node("sigma_muda")
onready var sfx_sigma_kejia: AudioStreamPlayer = get_parent().get_node("sigma_kejia")

onready var virus_sprite = animatedSprite.get_node("VirusSprite")
onready var virus_sprite_1 = virus_sprite.get_node("VirusSprite")
onready var virus_sprite_2 = virus_sprite.get_node("VirusSprite2")
onready var virus_sprite_3 = virus_sprite.get_node("VirusSprite3")

func _Setup() -> void :
	turn_and_face_player()
	play_animation("idle")
	character.emit_signal("damage_reduction", 0)
	if main.virus_start:
		EndAbility()

func _Update(delta: float) -> void :
	process_gravity(delta)
	
	if attack_stage == 0:
		play_animation("sigma_block")
		sfx_sigma_lauch3.play()
		virus_sprite.visible = true
		virus_sprite.animation = "empty"
		virus_sprite_1.animation = "sigma_virus_ready"
		virus_sprite_2.animation = "sigma_virus_ready"
		virus_sprite_3.animation = "sigma_virus_ready"
		virus_sprite_1.frame = 0
		virus_sprite_2.frame = 0
		virus_sprite_3.frame = 0
		next_attack_stage()
	
	elif attack_stage == 1:
		if virus_sprite_3.animation == "sigma_virus_ready" and virus_sprite_3.frame >= 8:
			virus_sprite_1.animation = "sigma_virus_loop"
			virus_sprite_2.animation = "sigma_virus_loop"
			virus_sprite_3.animation = "sigma_virus_loop"
			virus_sprite_1.get_node("DamageOnTouch").activate()
			virus_sprite_2.get_node("DamageOnTouch").activate()
			virus_sprite_3.get_node("DamageOnTouch").activate()
			main.virus_start = true
			next_attack_stage()
	
	elif attack_stage == 2 and timer > 2:
		play_animation("idle")
		EndAbility()

func _Interrupt() -> void :
	._Interrupt()
	character.emit_signal("damage_reduction", 1)
	#deactivate()

