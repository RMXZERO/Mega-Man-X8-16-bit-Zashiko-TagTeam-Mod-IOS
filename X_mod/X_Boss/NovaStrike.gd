extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")
onready var nova_strike: Node2D = $nova_strike
onready var nova_strike_sfx = $nova_strike_sfx
onready var crashbeam_sfx = $crashbeam
onready var damage: Node2D = $"../Damage"
onready var damage_on_touch: Node2D = $"../DamageOnTouch"
onready var laser = preload("res://X_mod/X_Boss/XRekohouha.tscn")
onready var nova_strike_back = $"../animatedSprite/animatedSprite"
onready var nova_strike_back_hit_box = $nova_strike/area2D/collisionShape2D

var start_speed = 1500
var jump_speed = 220
var horizontal_speed = start_speed
var damping = 0.95
var laser_casted: bool = false
var shot_time = 0

func _Setup() -> void :
	turn_and_face_player()
	play_animation("idle")
	nova_strike.handle_direction()
	jump_speed = 220
	horizontal_speed = 1200
	if boss_ai.used_desperation:
		horizontal_speed = 2000
		jump_speed = 270

func _Update(delta: float) -> void :
	if not animatedSprite.animation == "nova_strike":
		process_gravity(delta)
	
	if attack_stage == 0:
		if is_player_above(48) and is_player_nearby_horizontally(64) and not boss_ai.used_desperation:
			play_animation("ray_arrow_start")
			character.set_x_boss_ray_arrow_colors(animatedSprite)
			next_attack_stage()
		elif is_player_above(48) and is_player_nearby_horizontally(128) and boss_ai.used_desperation:
			play_animation("ray_arrow_start")
			character.set_x_boss_ray_arrow_colors(animatedSprite)
			next_attack_stage()
		else:
			play_animation("nova_strike_start")
			set_vertical_speed(-jump_speed)
			force_movement(250)
			go_to_attack_stage(2)
	
	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("ray_arrow")
		if boss_ai.used_desperation:
			screenshake(1.4)
		else:
			screenshake(0.7)
		fire_laser()
		go_to_attack_stage(10)
	
	elif attack_stage == 2 and has_finished_last_animation():
		if get_vertical_speed() > 0:
			set_vertical_speed(0)
		if boss_ai.used_desperation:
			play_animation("nova_strike")
			nova_strike_back.show()
			nova_strike_back.frame = 0
			nova_strike_back_hit_box.scale.x = 2
			nova_strike_back_hit_box.scale.y = 2
			screenshake(0.7)
		else:
			play_animation("nova_strike")
			nova_strike_back_hit_box.scale.x = 1
			nova_strike_back_hit_box.scale.y = 1
		nova_strike_sfx.play()
		next_attack_stage()

	elif attack_stage == 3:
		if damage_frames():
			nova_strike.activate()
			damage.deactivate()
			damage.active = false
			damage_on_touch.deactivate()
			damage_on_touch.active = false
		else:
			nova_strike.deactivate()
			nova_strike_back.hide()
			
		if movement_speed_frames():
			force_movement(horizontal_speed)
			set_vertical_speed(0)
			damp_horizontal_speed(delta)
		else:
			force_movement(300)
			
		if has_finished_last_animation():
			damage.activate()
			damage.active = true
			damage_on_touch.activate()
			damage_on_touch.active = true
			play_animation("fall")
			go_to_attack_stage(8)
		
	elif attack_stage == 8:
		kill_tweens(tween_list)
		if not character.is_on_floor() and animatedSprite.animation == "fall":
			set_vertical_speed(250)
		if character.is_on_floor():
			play_animation("recover")
			go_to_attack_stage(11)
	
	elif attack_stage == 9:
		kill_tweens(tween_list)
		play_animation("recover")
		next_attack_stage()
	
	elif attack_stage == 10 and has_finished_last_animation():
		kill_tweens(tween_list)
		play_animation("recover")
		next_attack_stage()
			
	elif attack_stage == 11 and character.is_on_floor():
		EndAbility()

func _Interrupt() -> void :
	._Interrupt()
	character.set_x_boss_normal_colors(animatedSprite)

func fire_laser() -> void :
	crashbeam_sfx.play()
	create_laser(global_position)
	create_laser(global_position + Vector2( + 30, 0))
	create_laser(global_position + Vector2( - 30, 0))
	create_laser(global_position + Vector2( + 60, 0))
	create_laser(global_position + Vector2( - 60, 0))
	if boss_ai.used_desperation:
		create_laser(global_position + Vector2( + 90, 0))
		create_laser(global_position + Vector2( - 90, 0))
		create_laser(global_position + Vector2( + 120, 0))
		create_laser(global_position + Vector2( - 120, 0))

func create_laser(ground_position) -> void :
	var instance = laser.instance()
	ground_position.y += 7
	instance.set_vertical_speed(-1200)
	instance.z_index = character.z_index + 10
	instance.get_node("DamageOnTouch").damage = 16
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.initialize(1)
	Event.emit_signal("screenshake", 0.5)

func damp_horizontal_speed(_delta: float) -> void :
	var reference_delta = 1.0 / 120
	var damping_factor = pow(damping, _delta / reference_delta)
	horizontal_speed *= damping_factor

func movement_speed_frames():
	return animatedSprite.frame >= 1 and animatedSprite.frame < 8

func end_saber_state():
	return animatedSprite.frame >= 9

func damage_frames():
	if animatedSprite.frame >= 0 and animatedSprite.frame < 9:
		return true
	return false
