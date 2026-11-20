extends AttackAbility

onready var boss_ai: = get_parent().get_node("BossAI")

onready var afterimages = animatedSprite.get_node("afterImages")

onready var damage: Node2D = $"../Damage"
onready var damagetouch: Node2D = $"../DamageOnTouch"
onready var normal_hitbox: CollisionShape2D = $"../collisionShape2D"
onready var dash_hitbox: CollisionShape2D = $"../dashcollisionShape2D"
onready var normal_damagetouch_hitbox: CollisionShape2D = $"../area2D/collisionShape2D"
onready var dash_damagetouch_hitbox: CollisionShape2D = $"../area2D/dashcollisionShape2D"

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

onready var sigmacrash: Node2D = $sigmacrash

var chance = randf() * 100
var sigma_crash_speed: = 620
var wall_speed_x: = 370
var wall_speed_y: = -80

func _Setup() -> void :
	turn_and_face_player()
	kill_tweens(tween_list)
	chance = randf() * 100
	sigmacrash.damage = 12
	sigma_crash_speed = 620
	wall_speed_x = 370
	wall_speed_y = -50
	main.dash_afterimages_on()
	if boss_ai.used_desperation:
		sigmacrash.damage = 16
		sigma_crash_speed = 720
		wall_speed_x = 420
		wall_speed_y = -80
	if is_player_nearby_horizontally(32) and not is_player_above(-16):
		EndAbility()

func _Update(_delta: float) -> void :
	if attack_stage == 0:
		play_animation("dash_start")
		normal_hitbox.disabled = true
		normal_damagetouch_hitbox.disabled = true
		dash_hitbox.disabled = false
		dash_damagetouch_hitbox.disabled = false
		if is_player_above(-16) or chance > 50:
			next_attack_stage()
		else:
			go_to_attack_stage(15)
		
	elif attack_stage == 1 and has_finished_last_animation():
		if get_forward_wall_position() < 200:
			turn()
		next_attack_stage()
		
	elif attack_stage == 2:
		jump_and_next_stage()
		
	elif attack_stage == 3:
		if has_finished_last_animation():
			play_animation_once("dash_loop")
		if is_colliding_with_wall():
			wallslide_and_next_stage()
			
	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("wall_slide")
		next_attack_stage()
		
	elif attack_stage == 5 and timer > 0.01:
		jump_and_next_stage()
		
	elif attack_stage == 6:
		if has_finished_last_animation():
			play_animation_once("dash_loop")
			
		if is_player_nearby_horizontally(48) and not is_player_above(-64):
			go_to_attack_stage(10)
			
		elif is_colliding_with_wall():
			wallslide_and_next_stage()
			
	elif attack_stage == 7 and has_finished_last_animation():
		play_animation("wall_slide")
		go_to_attack_stage(5)
		
	elif attack_stage == 10:
		play_animation("sigma_crash_ready")
		main.dash_afterimages_off()
		sigmacrash.handle_direction()
		force_movement(0)
		set_vertical_speed(0)
		next_attack_stage()
		
	elif attack_stage == 11 and has_finished_last_animation():
		play_animation("sigma_crash")
		set_vertical_speed(sigma_crash_speed)
		force_movement(128)
		sfx_dj_crash.play()
		sfx_sigma_muda.play()
		sigmacrash.activate()
		next_attack_stage()
		
	elif attack_stage == 12 and character.is_on_floor():
		play_animation("sigma_crash_land")
		force_movement(0)
		screenshake(1.4)
		next_attack_stage()
		
	elif attack_stage == 13 and has_finished_last_animation():
		play_animation("idle")
		sigmacrash.deactivate()
		next_attack_stage()
		
	elif attack_stage == 14 and has_finished_last_animation() or attack_stage == 13 and animatedSprite.animation == "idle":
		EndAbility()

	elif attack_stage == 15 and has_finished_last_animation():
		play_animation("dash_loop")
		sfx_dj_dash.play()
		force_movement(wall_speed_x)
		next_attack_stage()

	elif attack_stage == 16:
		if is_player_nearby_horizontally(8) or facing_a_wall():
			next_attack_stage()

	elif attack_stage == 17 and has_finished_last_animation():
		EndAbility()

func wallslide_and_next_stage() -> void :
	turn()
	adjust_position_to_wall(0)
	set_vertical_speed(0)
	play_animation("wall_slide")
	sfx_slide.play()
	decay_vert_speed()
	force_movement(0)
	next_attack_stage()

func jump_and_next_stage() -> void :
	play_animation("dash_loop")
	force_movement(wall_speed_x)
	set_vertical_speed(wall_speed_y)
	sfx_dj_dash.play()
	next_attack_stage()

func decay_vert_speed(duration: float = 0.15) -> void :
	var tween = get_tree().create_tween()
	tween.tween_method(self, "set_vertical_speed", - 50.0, 0.0, duration)

func _Interrupt() -> void :
	._Interrupt()
	normal_hitbox.disabled = false
	normal_damagetouch_hitbox.disabled = false
	dash_hitbox.disabled = true
	dash_damagetouch_hitbox.disabled = true
	main.dash_afterimages_off()
	kill_tweens(tween_list)


