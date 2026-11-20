extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")

export var dj_ball = preload("res://Zero_mod/Boss_DJSigma/Projectile/DJ_Ball.tscn")

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

var chance = randf() * 100
var ball_damage: float = 4

func _Setup() -> void :
	turn_and_face_player()
	play_animation("idle")
	ball_damage = 4
	if boss_ai.used_desperation:
		ball_damage = 6
	chance = randf() * 100
	if chance > 50:
		sfx_sigma_throw.play()
	else:
		sfx_sigma_kelei.play()

func _Update(delta: float) -> void :
	process_gravity(delta)
	
	if attack_stage == 0:
		play_animation("death_ball_ready")
		next_attack_stage()
	
	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("death_ball_fire")
		sfx_dj_ball.play()
		create_beamwave(global_position, 250, true)
		next_attack_stage()
	
	elif attack_stage == 2 and has_finished_last_animation():
		play_animation("death_ball_ready")
		next_attack_stage()
		
	elif attack_stage == 3 and has_finished_last_animation():
		play_animation("death_ball_fire")
		sfx_dj_ball.play()
		create_beamwave(global_position, 250, false)
		next_attack_stage()
		
	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("death_ball_ready")
		next_attack_stage()
		
	elif attack_stage == 5 and has_finished_last_animation():
		play_animation("death_ball_fire")
		sfx_dj_ball.play()
		create_beamwave(global_position, 250, true)
		create_beamwave(global_position, 250, false)
		next_attack_stage()
	
	elif attack_stage == 6 and timer > 0.1 and has_finished_last_animation():
		EndAbility()

func _Interrupt() -> void :
	._Interrupt()

func create_beamwave(ground_position, xspeed: float, go_up: bool) -> void :
	var instance = dj_ball.instance()
	ground_position.y += -16
	ground_position.x += 32 * get_facing_direction()
	instance.can_deflect = false
	instance.go_up = go_up
	instance.set_horizontal_speed(xspeed * get_facing_direction())
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.get_node("DamageOnTouch").damage = ball_damage
	instance.set_global_position(ground_position)
	instance.initialize(1)
