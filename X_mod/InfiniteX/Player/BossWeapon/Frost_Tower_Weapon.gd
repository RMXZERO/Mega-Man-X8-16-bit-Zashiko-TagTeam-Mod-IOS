extends MultiShotWeapon

onready var frost_tower_projectile: PackedScene = preload("res://X_mod/InfiniteX/Player/Projectiles/X4_frost_tower.tscn")
var camera_position: Vector2
var creator: Node2D
var frost_tower_damage = 5

func _ready() -> void :
	Event.listen("damage", self, "finish")
	Event.listen("player_death", self, "finish")
	character.listen("cutscene_deactivate", self, "finish")
	weapon_stasis.connect("interrupted", self, "finish")
	
func fire_charged() -> void :
	camera_position = GameManager.camera.get_camera_screen_center()
	$dive.play()
	executing = true
	character.add_invulnerability("DriftShoryuken")
	weapon_stasis.ExecuteOnce()
	weapon_stasis.play_animation_once("falcongiga")
	character.animatedSprite.material.set_shader_param("Alpha", 1)
	$"../../animatedSprite".frame = 8
	create_frost_tower(camera_position + Vector2(0, 0), frost_tower_damage)
	Tools.timer(0.5, "frost_tower_2", self)
	Tools.timer(1.0, "frost_tower_3", self)
	Tools.timer(1.5, "frost_tower_4", self)
	Tools.timer(1.8, "finish", self)

func frost_tower_2() -> void :
	create_frost_tower(camera_position + Vector2(50, 0), frost_tower_damage)
	create_frost_tower(camera_position + Vector2(-50, 0), frost_tower_damage)
	$dive.play()

func frost_tower_3() -> void :
	create_frost_tower(camera_position + Vector2(0, 0), frost_tower_damage)
	create_frost_tower(camera_position + Vector2(100, 0), frost_tower_damage)
	create_frost_tower(camera_position + Vector2(-100, 0), frost_tower_damage)
	$dive.play()

func frost_tower_4() -> void :
	create_frost_tower(camera_position + Vector2(50, 0), frost_tower_damage)
	create_frost_tower(camera_position + Vector2(-50, 0), frost_tower_damage)
	create_frost_tower(camera_position + Vector2(-150, 0), frost_tower_damage)
	create_frost_tower(camera_position + Vector2(150, 0), frost_tower_damage)
	$dive.play()

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

func create_frost_tower(ground_position,  damage_value) -> void :
	var instance = frost_tower_projectile.instance()
	ground_position.y += -64
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.damage = damage_value * 2 * extra_damage
	instance.damage_to_bosses = damage_value * extra_damage
	instance.damage_to_weakness = damage_value * 2 * extra_damage
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", character.get_facing_direction())
