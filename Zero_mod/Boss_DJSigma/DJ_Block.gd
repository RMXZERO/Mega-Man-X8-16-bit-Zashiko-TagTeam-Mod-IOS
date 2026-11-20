extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")

export var dj_block = preload("res://Zero_mod/Boss_DJSigma/Projectile/DJ_Block.tscn")

onready var damage: Node2D = $"../Damage"
onready var damagetouch: Node2D = $"../DamageOnTouch"
onready var normal_hitbox: CollisionShape2D = $"../collisionShape2D"
onready var block_hitbox: CollisionShape2D = $"../blockcollisionShape2D"
onready var normal_damagetouch_hitbox: CollisionShape2D = $"../area2D/collisionShape2D"
onready var block_damagetouch_hitbox: CollisionShape2D = $"../area2D/blockcollisionShape2D"

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

var last_position: Vector2
var hit_time: float = 0
var max_hit_time: float = 12
var was_move: bool = false
var is_go_up_or_down: bool = false
var camera_position: Vector2 = GameManager.camera.get_camera_screen_center()
var max_camera_position_x: float = camera_position.x + 200 - 56
var min_camera_position_x: float = camera_position.x - 200 + 56
var max_camera_position_y: float = camera_position.y - 112 + 52
var min_camera_position_y: float = camera_position.y + 112 - 52
var first_time_use = false
var range_use = randf() * 100

func _Setup() -> void :
	turn_and_face_player()
	range_use = randf() * 100
	last_position = character.global_position
	camera_position = GameManager.camera.get_camera_screen_center()
	max_camera_position_x = camera_position.x + 200 - 56
	min_camera_position_x = camera_position.x - 200 + 56
	max_camera_position_y = camera_position.y - 112 + 52
	min_camera_position_y = camera_position.y + 112 - 52
	hit_time = 0
	max_hit_time = 12 + CharacterManager.game_mode * 2
	if range_use < 75 and first_time_use:
		EndAbility()
	if not boss_ai.used_desperation:
		EndAbility()

func _Update(delta: float) -> void :
	if attack_stage == 0:
		play_animation("sigma_block")
		var chance = randf() * 100
		if chance > 50:
			sfx_sigma_kejia.play()
		else:
			sfx_sigma_owld.play()
		next_attack_stage()
	
	elif attack_stage == 1 and timer > 1.5:
		play_animation("teleport_out_land")
		damage.deactivate()
		damagetouch.deactivate()
		next_attack_stage()
	
	elif attack_stage == 2 and has_finished_last_animation():
		normal_hitbox.disabled = true
		normal_damagetouch_hitbox.disabled = true
		block_hitbox.disabled = false
		block_damagetouch_hitbox.disabled = false
		next_attack_stage()
		var l = 7.2 + CharacterManager.game_mode * 0.6 * 3
		var i = 0.6
		while i <= l:
			Tools.timer(i, "block_attack", self)
			i += 0.6
			if i > l:
				Tools.timer(i, "next_attack_stage", self)
		
	elif attack_stage == 3:
		pass

	elif attack_stage == 4:
		damagetouch.activate()
		play_animation("block_loop")
		turn_and_face_player()
		timer = 0
		next_attack_stage()

	elif attack_stage == 5 and timer > 0.6:
		timer = 0
		was_move = true
		var player_position_y: float = GameManager.player.global_position.y
		if not is_player_above(53):
			if character.global_position.y + 53 <= player_position_y:
				var chance = randf() * 100
				if chance > 50 or is_player_nearby_horizontally(56):
					set_vertical_speed(250)
					is_go_up_or_down = true
					next_attack_stage()
				else:
					force_movement(300)
					is_go_up_or_down = false
					next_attack_stage()
			else:
				force_movement(300)
				is_go_up_or_down = false
				next_attack_stage()
		else:
			if character.global_position.y <= player_position_y:
				if is_player_nearby_horizontally(56):
					set_vertical_speed(250)
					is_go_up_or_down = true
					next_attack_stage()
				else:
					force_movement(300)
					is_go_up_or_down = false
					next_attack_stage()
			elif character.global_position.y > player_position_y:
				var chance = randf() * 100
				if chance > 50 or is_player_nearby_horizontally(56):
					set_vertical_speed(-250)
					is_go_up_or_down = true
					next_attack_stage()
				else:
					force_movement(300)
					is_go_up_or_down = false
					next_attack_stage()
			
	elif attack_stage == 6 and timer > 0.1:
		if not is_go_up_or_down:
			if character.global_position.x >= max_camera_position_x - 20 or \
			character.global_position.x <= min_camera_position_x + 20:
				timer = 0
				sfx_dj_block_hit.play()
				screenshake(2)
				turn_and_face_player()
				if hit_time <= max_hit_time:
					go_to_attack_stage(5)
				else:
					go_to_attack_stage(7)
		if is_go_up_or_down:
			if character.global_position.y <= max_camera_position_y + 10:
				character.global_position.y = max_camera_position_y
				set_vertical_speed(0)
				timer = 0
				sfx_dj_block_hit.play()
				screenshake(2)
				turn_and_face_player()
				if hit_time <= max_hit_time:
					go_to_attack_stage(5)
				else:
					go_to_attack_stage(7)
			if character.is_on_floor():
				set_vertical_speed(0)
				timer = 0
				sfx_dj_block_hit.play()
				screenshake(2)
				turn_and_face_player()
				if hit_time <= max_hit_time:
					go_to_attack_stage(5)
				else:
					go_to_attack_stage(7)
		if was_move:
			was_move = false
			hit_time += 1

	elif attack_stage == 7 and timer > 1.0:
		force_movement(0)
		set_vertical_speed(0)
		damagetouch.deactivate()
		play_animation("empty")
		normal_hitbox.disabled = false
		normal_damagetouch_hitbox.disabled = false
		block_hitbox.disabled = true
		block_damagetouch_hitbox.disabled = true
		timer = 0
		next_attack_stage()

	elif attack_stage == 8 and timer > 0.6:
		character.global_position = last_position
		next_attack_stage()

	elif attack_stage == 9 and timer > 0.6:
		play_animation("teleport_in_land")
		next_attack_stage()

	elif attack_stage == 10 and has_finished_last_animation():
		damage.activate()
		damagetouch.activate()
		play_animation("idle")
		first_time_use = true
		EndAbility()

func _Interrupt() -> void :
	._Interrupt()
	normal_hitbox.disabled = false
	normal_damagetouch_hitbox.disabled = false
	block_hitbox.disabled = true
	block_damagetouch_hitbox.disabled = true
	damage.activate()
	damagetouch.activate()

func block_attack() -> void :
	create_dj_block()
	sfx_dj_block.play()

func create_dj_block() -> void :
	var instance = dj_block.instance()
	var player_position: Vector2 = GameManager.player.global_position
	var final_position: Vector2 = GameManager.player.global_position
	if player_position.x > max_camera_position_x:
		final_position.x = max_camera_position_x
	elif player_position.x < min_camera_position_x:
		final_position.x = min_camera_position_x
	elif player_position.x < max_camera_position_x and player_position.x > min_camera_position_x:
		final_position.x = player_position.x
	if player_position.y < max_camera_position_y:
		final_position.y = max_camera_position_y
	elif player_position.y > min_camera_position_y:
		final_position.y = min_camera_position_y
	elif player_position.y < min_camera_position_y and player_position.y > max_camera_position_y:
		final_position.y = player_position.y
	instance.get_node("animatedSprite").animation = "block_ready"
	instance.get_node("animatedSprite").frame = 0
	instance.get_node("DamageOnTouch").damage = 16
	instance.can_deflect = false
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(final_position)
	instance.initialize(1)
	character.global_position = final_position

