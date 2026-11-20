extends BossWeapon

var current_shield: Node
onready var ray_gun_projectile: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/RekohouhaX6.tscn")
var creator: Node2D
var ray_gun_damage = 10

var executing: = false
onready var tween: = TweenController.new(self, false)
onready var weapon_stasis: Node2D = $"../../WeaponStasis"

func _ready() -> void :
	Event.listen("damage", self, "finish")
	Event.listen("player_death", self, "finish")
	character.listen("cutscene_deactivate", self, "finish")
	weapon_stasis.connect("interrupted", self, "finish")

func fire_regular() -> void :
	play(weapon.sound)
	if is_instance_valid(current_shield):
		current_shield.expire()
	current_shield = instantiate_projectile(weapon.regular_shot)
	set_position_as_shot_position(current_shield)

func fire_charged() -> void :
	executing = true
	character.add_invulnerability("DriftShoryuken")
	weapon_stasis.ExecuteOnce()
	weapon_stasis.play_animation_once("falcongiga")
	character.animatedSprite.material.set_shader_param("Alpha", 1)
	$"../../animatedSprite".frame = 8
	$crashbeam.play()
	create_ray_gun(character.global_position, -1)
	create_ray_gun(character.global_position + Vector2(30, 0), -1)
	create_ray_gun(character.global_position + Vector2(- 30, 0), -1)
	create_ray_gun(character.global_position + Vector2(60, 0), -1)
	create_ray_gun(character.global_position + Vector2(- 60, 0), -1)
	create_ray_gun(character.global_position + Vector2(90, 0), -1)
	create_ray_gun(character.global_position + Vector2(- 90, 0), -1)
	Tools.timer(0.5, "finish", self)

func finish() -> void :
	if executing:
		executing = false
		weapon_stasis.EndAbility()
		character.set_horizontal_speed(0)
		character.set_vertical_speed(0)
		tween.reset()
		Tools.timer_p(0.25, "remove_invulnerability", character, "DriftShoryuken")

func _on_Forced_ability_start(_ability) -> void :
	if executing:
		finish()

func create_ray_gun(ground_position, down_value) -> void :
	var instance = ray_gun_projectile.instance()
	ground_position.y += 0
	instance.damage = ray_gun_damage * 2 * extra_damage
	instance.damage_to_bosses = ray_gun_damage * extra_damage
	instance.damage_to_weakness = ray_gun_damage * 2 * extra_damage
	instance.speed = 1200 * down_value
	instance.scale.y = 1 * down_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", character.get_facing_direction())
	Event.emit_signal("screenshake", 0.3)
