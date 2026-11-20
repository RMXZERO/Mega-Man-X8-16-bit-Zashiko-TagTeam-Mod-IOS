extends MultiShotWeapon

onready var soul_body_projectile: PackedScene = preload("res://X_mod/InfiniteX/Player/Projectiles/X4_soul_body.tscn")
var creator: Node2D
var sould_body_damage = 5

func fire_charged() -> void :
	executing = true
	character.add_invulnerability("DriftShoryuken")
	weapon_stasis.ExecuteOnce()
	weapon_stasis.play_animation_once("falcongiga")
	character.animatedSprite.material.set_shader_param("Alpha", 1)
	$"../../animatedSprite".frame = 8
	frost_tower_2()
	Tools.timer(0.1, "frost_tower_2", self)
	Tools.timer(0.2, "frost_tower_2", self)
	Tools.timer(0.3, "frost_tower_2", self)
	Tools.timer(0.4, "frost_tower_2", self)
	Tools.timer(0.5, "frost_tower_2", self)
	Tools.timer(0.6, "frost_tower_2", self)
	Tools.timer(0.7, "frost_tower_2", self)
	Tools.timer(0.8, "frost_tower_2", self)
	Tools.timer(0.9, "frost_tower_2", self)
	Tools.timer(1.0, "finish", self)

func frost_tower_2() -> void :
	$shot.play()
	create_soul_body(character.global_position, sould_body_damage)

func define_direction(_driftshoryuken) -> int:
	var dir = 0
	if Input.is_action_pressed("move_left"):
		dir = - 1
	elif Input.is_action_pressed("move_right"):
		dir = 1
	if dir != 0:
		character.set_direction(dir)
	else:
		dir = character.get_facing_direction()
	return dir

func finish() -> void :
	if executing:
		executing = false
		if is_instance_valid(driftshoryuken):
			driftshoryuken.finish()
		weapon_stasis.EndAbility()
		character.set_horizontal_speed(0)
		character.set_vertical_speed(0)
		tween.reset()
		Tools.timer_p(0.25, "remove_invulnerability", character, "DriftShoryuken")

func _on_Forced_ability_start(_ability) -> void :
	if executing:
		finish()

func create_soul_body(ground_position,  damage_value) -> void :
	var instance = soul_body_projectile.instance()
	ground_position.y += 0
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.damage = damage_value * 2 * extra_damage
	instance.damage_to_bosses = damage_value * extra_damage
	instance.damage_to_weakness = damage_value * 2 * extra_damage
	instance.set_vertical_speed((0 + rand_range( - 50, 50))* character.get_facing_direction())
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", character.get_facing_direction())
