extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")

onready var shoryuuken: Node2D = $shoryuuken
onready var shoryuuken_sfx = $shoryuuken/shoryuuken_sfx
onready var buster_sfx = $buster

onready var mini_laser = preload("res://X_mod/X_Boss/XAuxiliaryBuster.tscn")
onready var ultimate_laser = preload("res://X_mod/X_Boss/XChargeBuster.tscn")

onready var dash_smoke: Particles2D = $"../animatedSprite/Dash Smoke Particles"

onready var sfx_saber1: AudioStreamPlayer = get_parent().get_node("saber")
onready var sfx_saber2: AudioStreamPlayer = get_parent().get_node("saber2")
onready var sfx_saber3: AudioStreamPlayer = get_parent().get_node("saber3")
onready var sfx_dash: AudioStreamPlayer = get_parent().get_node("dash")
onready var sfx_jump: AudioStreamPlayer = get_parent().get_node("jump")
onready var sfx_land: AudioStreamPlayer = get_parent().get_node("land")

var dash_speed: = 300
var fire_laser: bool = false
var can_use_again: bool = false
var shot_time: = 0.5

func _Setup() -> void :
	turn_and_face_player()
	play_animation("attack_start")
	shoryuuken.handle_direction()
	fire_laser = false
	shot_time = 0.5
	if boss_ai.used_desperation:
		shoryuuken.damage = 8
		shot_time = 0.4
	if CharacterManager.nightshade_zero_armor:
		dash_speed = 400
		shot_time = 0.4

func _Update(delta: float) -> void :
	process_gravity(delta)
	if animatedSprite.animation == "shot":
		turn_and_face_player()
		force_movement(0)
		set_vertical_speed(400)
	
	if attack_stage == 0:
		if not is_player_nearby_horizontally(192) and is_player_above(64) and can_use_again:
			go_to_attack_stage(8)
		elif is_player_nearby_horizontally(48) and is_player_above(64):
			shoryuuken_slash()
			go_to_attack_stage(6)
		else:
			play_animation("dash")
			sfx_dash.play()
		
			dash_smoke.emitting = true
			force_movement(dash_speed)
			next_attack_stage()
	
	elif attack_stage == 1 and timer > 0.1:
		if is_player_nearby_horizontally(192.0) or timer > 1 or facing_a_wall():
			if is_player_nearby_vertically(24) and not is_player_above(64):
				play_animation("shot_dash")
				fire_laser()
				force_movement(dash_speed)
				go_to_attack_stage(2)
			elif is_player_nearby_horizontally(64.0) and is_player_above(64):
				shoryuuken_slash()
				go_to_attack_stage(6)
			elif facing_a_wall() and not is_player_nearby_horizontally(64.0):
				go_to_attack_stage(8)
				
	elif attack_stage == 2 and timer > 0.2 and has_finished_last_animation():
		turn_and_face_player()
		play_animation("attack_start")
		dash_smoke.emitting = false
		force_movement(0)
		next_attack_stage()
				
	elif attack_stage == 3 and timer > 0.2 and has_finished_last_animation():
		turn_and_face_player()
		play_animation("shot")
		fire_mini_laser()
		force_movement(0)
		next_attack_stage()
		
	elif attack_stage == 4 and timer > 0.2 and has_finished_last_animation():
		kill_tweens(tween_list)
		turn_and_face_player()
		play_animation("dash")
		sfx_dash.play()
		dash_smoke.emitting = true
		timer = 0
		force_movement(dash_speed)
		next_attack_stage()
		
	elif attack_stage == 5 and timer > 0.2:
		if is_player_nearby_horizontally(64) and not is_player_above(96):
			play_animation("jump")
			force_movement(- dash_speed * 0.75)
			set_vertical_speed( - 300)
				
			sfx_jump.play()
			call_deferred("decay_speed", 1, 1.25)
			dash_smoke.emitting = false
			next_attack_stage()
		if facing_a_wall() or character.is_colliding_with_wall():
			go_to_attack_stage(8)

	elif attack_stage == 6 and timer > 0.1:
		if get_vertical_speed() > 0:
			play_animation("fall")
			next_attack_stage()
			
	elif attack_stage == 7 and timer > 0.1:
		if character.is_on_floor():
			play_animation("shot_recover")
			sfx_land.play()
			force_movement(0)
			go_to_attack_stage(10)
			
	elif attack_stage == 8 and timer > 0.1:
		dash_smoke.emitting = false
		if boss_ai.used_desperation:
			if not fire_laser:
				fire_laser = true
				can_use_again = false
				play_animation("shot")
				fire_laser_lock_player()
				Tools.timer(shot_time, "fire_laser_lock_player", self)
				Tools.timer(shot_time * 2, "fire_laser_lock_player", self)
				Tools.timer(shot_time * 3, "fire_laser_lock_player", self)
				Tools.timer(shot_time * 4, "fire_laser_lock_player", self)
				Tools.timer(shot_time * 5, "EndAbility", self)
		else:
			go_to_attack_stage(10)
					
	elif attack_stage == 10 and has_finished_last_animation():
		EndAbility()

func _Interrupt() -> void :
	._Interrupt()
	Tools.timer(3, "reset_can_use_again", self)
	dash_smoke.emitting = false

func reset_can_use_again() -> void :
	can_use_again = true

func shoryuuken_slash():
	shoryuuken.activate()
	play_animation("shoryuuken")
	force_movement(200)
	set_vertical_speed( - 400)
	call_deferred("decay_speed", 1, 1.25)
	shoryuuken_sfx.play()
	
	dash_smoke.emitting = false

func fire_laser() -> void :
	animatedSprite.frame = 0
	buster_sfx.play()
	create_ultimate_laser(global_position, 0)
	if boss_ai.used_desperation:
		create_mini_laser(global_position, 150)
		create_mini_laser(global_position, -150)

func fire_mini_laser() -> void :
	animatedSprite.frame = 0
	buster_sfx.play()
	if boss_ai.used_desperation:
		create_ultimate_laser(global_position, 0)
		create_mini_laser(global_position, 150)
		create_mini_laser(global_position, -150)
	else:
		create_mini_laser(global_position, 0)

func fire_ultimate_laser() -> void :
	create_ultimate_laser(global_position, 0)

func fire_laser_lock_player() -> void :
	if not animatedSprite.animation == "shot":
		return
	animatedSprite.frame = 0
	buster_sfx.play()
	create_ultimate_laser_lock_player(global_position, 0)

func create_mini_laser(ground_position,y_speed) -> void :
	var instance = mini_laser.instance()
	ground_position.y += 0
	instance.set_horizontal_speed(400 * get_facing_direction())
	instance.set_vertical_speed(y_speed)
	instance.scale.x = get_facing_direction()
	instance.can_deflect = true
	instance.z_index = character.z_index + 10
	instance.get_node("DamageOnTouch").damage = 8
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.initialize(1)

func create_ultimate_laser(ground_position,y_speed) -> void :
	var instance = ultimate_laser.instance()
	ground_position.y += 0
	instance.set_horizontal_speed(500 * get_facing_direction())
	instance.set_vertical_speed(y_speed)
	instance.scale.x = get_facing_direction()
	if not boss_ai.used_desperation:
		instance.can_deflect = true
	instance.z_index = character.z_index + 10
	instance.get_node("DamageOnTouch").damage = 8
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.initialize(1)

func create_ultimate_laser_lock_player(ground_position,y_speed) -> void :
	var instance = instantiate_projectile(ultimate_laser)
	var spawn_position = Vector2(position.x * character.get_facing_direction(), position.y)
	var target_dir = get_player_angle(character.global_position + spawn_position)
	instance.global_position = character.global_position + spawn_position
	if not boss_ai.used_desperation:
		instance.can_deflect = true
	instance.set_horizontal_speed( 500 * target_dir.x)
	instance.set_vertical_speed( 500 * target_dir.y)
	instance.set_rotation(Vector2(500 * target_dir.x, 500 * target_dir.y).angle())
	instance.get_node("DamageOnTouch").damage = 8

func get_player_angle(global_position : Vector2) -> Vector2:
	var speed = clamp(GameManager.player.get_horizontal_speed(),-30,30)
	var player_pos = GameManager.get_player_position() + Vector2(speed,-5)
	
	return ((player_pos) - global_position).normalized()
