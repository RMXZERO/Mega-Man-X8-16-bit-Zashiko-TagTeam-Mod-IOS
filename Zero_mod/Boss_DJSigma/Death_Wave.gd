extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")

export var dj_wave = preload("res://Zero_mod/Boss_DJSigma/Projectile/DJ_Wave.tscn")

onready var damage: Node2D = $"../Damage"
onready var damagetouch: Node2D = $"../DamageOnTouch"

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

onready var wave_effect: AnimatedSprite = animatedSprite.get_node_or_null("effectSprite")

var chance = randf() * 100
var wave_damage: float = 6
var attack_timer: float = 1.5
var last_position: Vector2

func _Setup() -> void :
	chance = randf() * 100
	turn_and_face_player()
	play_animation("teleport_out_land")
	damage.deactivate()
	damagetouch.deactivate()
	wave_damage = 6
	attack_timer = 1.5 - CharacterManager.game_mode * 0.1
	wave_effect.visible = true
	last_position = character.global_position
	sfx_dj_teleport.play()
	if boss_ai.used_desperation:
		wave_damage = 10
	if chance > 50:
		sfx_sigma_lauch.play()

func _Update(delta: float) -> void :
	if attack_stage == 0:
		next_attack_stage()
	
	elif attack_stage == 1 and has_finished_last_animation():
		character.global_position = GameManager.camera.get_camera_screen_center()
		if chance > 50:
			character.global_position.x = GameManager.camera.get_camera_screen_center().x - 180
		else:
			character.global_position.x = GameManager.camera.get_camera_screen_center().x + 180
		turn_and_face_player()
		next_attack_stage()
	
	elif attack_stage == 2 and has_finished_last_animation():
		play_animation("teleport_in_air")
		next_attack_stage()
		
	elif attack_stage == 3 and has_finished_last_animation():
		damage.activate()
		damagetouch.activate()
		next_attack_stage()
		
	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("death_wave_ready")
		next_attack_stage()
		
	elif attack_stage == 5 and has_finished_last_animation():
		play_animation("death_wave_fire")
		sfx_dj_wave.play()
		sfx_sigma_easy.play()
		create_wave()
		wave_effect.frame = 0
		timer = 0
		next_attack_stage()
		
	elif attack_stage == 6 and has_finished_last_animation() and timer > attack_timer:
		play_animation("death_wave_ready")
		next_attack_stage()
		
	elif attack_stage == 7 and has_finished_last_animation():
		play_animation("death_wave_fire")
		sfx_dj_wave.play()
		sfx_sigma_lauch2.play()
		create_wave()
		wave_effect.frame = 0
		timer = 0
		next_attack_stage()
	
	elif attack_stage == 8 and has_finished_last_animation() and timer > attack_timer:
		play_animation("death_wave_ready")
		next_attack_stage()
		
	elif attack_stage == 9 and has_finished_last_animation():
		play_animation("death_wave_fire")
		sfx_dj_wave.play()
		create_double_wave()
		wave_effect.frame = 0
		timer = 0
		next_attack_stage()
		
	elif attack_stage == 10 and has_finished_last_animation() and timer > attack_timer:
		play_animation("death_wave_ready")
		next_attack_stage()
		
	elif attack_stage == 11 and has_finished_last_animation():
		play_animation("death_wave_fire")
		sfx_dj_wave.play()
		if chance > 50:
			create_wave()
		else:
			create_double_wave()
		wave_effect.frame = 0
		timer = 0
		next_attack_stage()
	
	elif attack_stage == 12 and has_finished_last_animation() and timer > attack_timer:
		play_animation("teleport_out_air")
		damage.deactivate()
		damagetouch.deactivate()
		sfx_dj_teleport.play()
		next_attack_stage()
	
	elif attack_stage == 13 and has_finished_last_animation():
		character.global_position = last_position
		turn_and_face_player()
		next_attack_stage()
	
	elif attack_stage == 14 and has_finished_last_animation():
		play_animation("teleport_in_land")
		go_to_attack_stage(20)
	
	elif attack_stage == 20 and timer > 0.1 and has_finished_last_animation():
		damage.activate()
		damagetouch.activate()
		EndAbility()

func _Interrupt() -> void :
	._Interrupt()
	damage.activate()
	damagetouch.activate()

func create_wave() -> void :
	var instance = dj_wave.instance()
	var ground_position: Vector2 = GameManager.camera.get_camera_screen_center()
	var chance_projectile = randf() * 100
	if chance_projectile > 75:
		ground_position.y += -42
	elif chance_projectile < 25:
		ground_position.y += 42
	ground_position.x = character.global_position.x + 16 * get_facing_direction()
	if character.facing_right:
		instance.rotate_degrees(0)
	else:
		instance.rotate_degrees(180)
	instance.can_deflect = false
	instance.set_horizontal_speed(250 * get_facing_direction())
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.get_node("DamageOnTouch").damage = wave_damage
	instance.set_global_position(ground_position)
	instance.initialize(1)

func create_double_wave() -> void :
	double_wave_up()
	double_wave_down()

func double_wave_up() -> void :
	var instance = dj_wave.instance()
	var ground_position: Vector2 = GameManager.camera.get_camera_screen_center()
	ground_position.y += 112
	ground_position.x = character.global_position.x + 16 * get_facing_direction()
	if character.facing_right:
		instance.rotate_degrees(0)
	else:
		instance.rotate_degrees(180)
	instance.can_deflect = false
	instance.set_horizontal_speed(250 * get_facing_direction())
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.get_node("DamageOnTouch").damage = wave_damage
	instance.set_global_position(ground_position)
	instance.initialize(1)

func double_wave_down() -> void :
	var instance = dj_wave.instance()
	var ground_position: Vector2 = GameManager.camera.get_camera_screen_center()
	var chance_projectile = randf() * 100
	ground_position.y += -112
	ground_position.x = character.global_position.x + 16 * get_facing_direction()
	if character.facing_right:
		instance.rotate_degrees(0)
	else:
		instance.rotate_degrees(180)
	instance.can_deflect = false
	instance.set_horizontal_speed(250 * get_facing_direction())
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.get_node("DamageOnTouch").damage = wave_damage
	instance.set_global_position(ground_position)
	instance.initialize(1)
