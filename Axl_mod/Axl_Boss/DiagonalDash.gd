extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")
onready var main = get_parent()
onready var space = $"../Space"

onready var bullet_sfx = $shot
onready var diagonal_dash_sfx = $dash
onready var bullet = preload("res://Axl_mod/Axl_Boss/BossBullet.tscn")

onready var dash_smoke: Particles2D = $"../animatedSprite/Dash Smoke Particles"

onready var sfx_dash: AudioStreamPlayer = get_parent().get_node("dash")
onready var sfx_jump: AudioStreamPlayer = get_parent().get_node("jump")
onready var sfx_land: AudioStreamPlayer = get_parent().get_node("land")

var diagonal_dash_speed: = 600
var fire_laser: bool = false
var shot_time: = 0.1
var dash_time: float = 0

func _Setup() -> void :
	turn_and_face_player()
	fire_laser = false
	shot_time = 0.1
	dash_time = 0
	if boss_ai.used_desperation:
		shot_time = 0.075
	if CharacterManager.nightshade_zero_armor:
		diagonal_dash_speed = 800
		shot_time = 0.05

func fire_again() -> void :
	fire_laser = false

func next_attack_stage() -> void :
	.next_attack_stage()

func _Update(delta: float) -> void :
	if not animatedSprite.animation == "slide" and not animatedSprite.animation == "diagonal_dash":
		process_gravity(delta)
	if not fire_laser:
		if animatedSprite.animation == "rolling":
			fire_bullet_lock_player()
			Tools.timer(shot_time, "fire_again", self)
			fire_laser = true
	
	if attack_stage == 0:
		play_animation("jump")
		sfx_jump.play()
		force_movement(-311)
		set_vertical_speed(-585)
		next_attack_stage()
	
	elif attack_stage == 1 and timer > 0.1 and character.is_colliding_with_wall():
		if global_position.y < main.land_position.y - 128:
			timer = 0
			play_animation("slide")
			set_vertical_speed(0)
			next_attack_stage()
		if character.is_on_floor():
			go_to_attack_stage(0)

	elif attack_stage == 2 and has_finished_last_animation() and timer > 0.5:
		timer = 0
		diagonal_dash_sfx.play()
		play_animation("diagonal_dash")
		force_movement(diagonal_dash_speed)
		next_attack_stage()
			
	elif attack_stage == 3 and facing_a_wall() and timer > 0.5:
		timer = 0
		turn()
		play_animation("slide")
		set_vertical_speed(0)
		next_attack_stage()
		
	elif attack_stage == 4 and has_finished_last_animation() and timer > 0.5:
		timer = 0
		diagonal_dash_sfx.play()
		play_animation("diagonal_dash")
		force_movement(diagonal_dash_speed)
		set_vertical_speed(diagonal_dash_speed * 0.2)
		next_attack_stage()

	elif attack_stage == 5 and character.is_on_floor() or attack_stage == 5 and facing_a_wall():
		turn()
		set_vertical_speed(0)
		if character.is_on_floor() or global_position.y >  main.land_position.y -4:
			play_animation("idle")
			force_movement(0)
			timer = 0.6
			next_attack_stage()
		else:
			play_animation("slide")
			force_movement(diagonal_dash_speed)
			timer = 0
			next_attack_stage()
			
	elif attack_stage == 6 and timer > 0.5:
		diagonal_dash_sfx.play()
		play_animation("diagonal_dash")
		var target_dir = get_player_angle(character.global_position)
		set_horizontal_speed(diagonal_dash_speed * target_dir.x)
		set_vertical_speed(diagonal_dash_speed * target_dir.y)
		dash_time += 1
		next_attack_stage()
			
	elif attack_stage == 7 and timer > 0.2:
		if character.is_on_floor() or global_position.y >  main.land_position.y -4:
			go_to_attack_stage(11)
		elif facing_a_wall():
			play_animation("slide")
			set_vertical_speed(0)
			turn()
			timer = 0.6
			if dash_time <= 7:
				go_to_attack_stage(6)
			else:
				go_to_attack_stage(8)
		elif timer > 2.6:
			go_to_attack_stage(8)
	
	elif attack_stage == 8 and timer > 0.5:
		play_animation("rolling")
		sfx_jump.play()
		force_movement(311)
		set_vertical_speed(-435)
		next_attack_stage()

	elif attack_stage == 9 and character.is_on_floor() or attack_stage == 9 and global_position.y > main.land_position.y -4:
		set_vertical_speed(50)
		go_to_attack_stage(11)
		
	elif attack_stage == 10 and timer > 0.5:
		turn_and_face_player()
		diagonal_dash_sfx.play()
		play_animation("diagonal_dash")
		var target_dir = get_player_angle(character.global_position)
		set_horizontal_speed(diagonal_dash_speed * target_dir.x)
		set_vertical_speed(diagonal_dash_speed * target_dir.y)
		go_to_attack_stage(7)
		
	elif attack_stage >= 11:
		EndAbility()

func _Interrupt() -> void :
	._Interrupt()
	main.use_desperation += 1
	dash_smoke.emitting = false

func fire_bullet_lock_player() -> void :
	bullet_sfx.play()
	create_bullet_lock_player(global_position)

func create_bullet_lock_player(ground_position) -> void :
	var instance = instantiate_projectile(bullet)
	var spawn_position = Vector2(position.x * character.get_facing_direction(), position.y)
	var target_dir = get_player_angle(character.global_position + spawn_position)
	
	instance.global_position = character.global_position + spawn_position
	instance.set_horizontal_speed( 450 * target_dir.x)
	instance.set_vertical_speed( 450 * target_dir.y)
	instance.set_rotation(Vector2(450 * target_dir.x, 450 * target_dir.y).angle())
	if animatedSprite.animation == "shot_1":
		instance.set_global_position(global_position + Vector2( 2 * get_facing_direction(), -36))
	elif animatedSprite.animation == "shot_2":
		instance.set_global_position(global_position + Vector2( 26 * get_facing_direction(), -30))
	elif animatedSprite.animation == "shot_3":
		instance.set_global_position(global_position + Vector2( + 36 * get_facing_direction(), -8))
	elif animatedSprite.animation == "shot_4":
		instance.set_global_position(global_position + Vector2( 30 * get_facing_direction(), 14))
	elif animatedSprite.animation == "shot_5":
		instance.set_global_position(global_position + Vector2( 10 * get_facing_direction(), 28))
	else:
		instance.set_global_position(global_position + Vector2( -8 * get_facing_direction(), 0))
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)

func get_player_angle(global_position : Vector2) -> Vector2:
	var speed = clamp(GameManager.player.get_horizontal_speed(),-30,30)
	var player_pos = GameManager.get_player_position() + Vector2(speed,-5)
	return ((player_pos) - global_position).normalized()
