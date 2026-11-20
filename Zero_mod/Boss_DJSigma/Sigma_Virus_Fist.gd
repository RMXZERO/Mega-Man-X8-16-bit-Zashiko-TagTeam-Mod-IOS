extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")

onready var damage: Node2D = $"../Damage"
onready var damagetouch: Node2D = $"../DamageOnTouch"
onready var sigmavriusfist: Node2D = $sigmavriusfist

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

var dash_speed: = 400
var chance = randf() * 100
var last_position: Vector2

func _Setup() -> void :
	chance = randf() * 100
	turn_and_face_player()
	play_animation("teleport_out_land")
	damage.deactivate()
	damagetouch.deactivate()
	last_position = character.global_position
	sfx_dj_teleport.play()
	if chance > 50:
		sfx_sigma_lauch.play()

func _Update(delta: float) -> void :
	if attack_stage == 0:
		next_attack_stage()
	
	elif attack_stage == 1 and has_finished_last_animation():
		character.global_position.x = GameManager.get_player_position().x
		if GameManager.get_player_position().y < last_position.y:
			character.global_position.y = GameManager.get_player_position().y
		else:
			character.global_position.y = last_position.y
		turn_and_face_player()
		next_attack_stage()
	
	elif attack_stage == 2 and has_finished_last_animation():
		damage.deactivate()
		sfx_dj_teleport.play()
		play_animation("sigma_virus_fist_in")
		next_attack_stage()
		
	elif attack_stage == 3 and has_finished_last_animation():
		damage.activate()
		sigmavriusfist.activate()
		sfx_sigma_kelei.play()
		play_animation("sigma_virus_fist_attack")
		next_attack_stage()
		
	elif attack_stage == 4 and has_finished_last_animation():
		damage.deactivate()
		sigmavriusfist.deactivate()
		sfx_dj_teleport.play()
		play_animation("sigma_virus_fist_out")
		next_attack_stage()
	
	elif attack_stage == 5 and has_finished_last_animation():
		character.global_position = last_position
		turn_and_face_player()
		next_attack_stage()
	
	elif attack_stage == 6 and has_finished_last_animation():
		sfx_dj_teleport.play()
		play_animation("teleport_in_land")
		go_to_attack_stage(20)
	
	elif attack_stage == 20 and timer > 0.1 and has_finished_last_animation():
		damage.activate()
		damagetouch.activate()
		EndAbility()

func _Interrupt() -> void :
	._Interrupt()
	sigmavriusfist.deactivate()
	damagetouch.activate()
	damage.activate()

