extends BossWeapon

onready var double_cyclone_projectile: PackedScene = preload("res://X_mod/InfiniteX/Player/Projectiles/X4_double_cyclone.tscn")
var creator: Node2D
var double_cyclone_damage = 5

var executing: = false
onready var tween: = TweenController.new(self, false)
onready var weapon_stasis: Node2D = $"../../WeaponStasis"

func _ready() -> void :
	Event.listen("damage", self, "finish")
	Event.listen("player_death", self, "finish")
	character.listen("cutscene_deactivate", self, "finish")
	weapon_stasis.connect("interrupted", self, "finish")

func fire_regular() -> void :
	play(weapon.charged_sound)
	var shot = instantiate_projectile(weapon.charged_shot)
	set_position_as_shot_position(shot, - 24.0)
	set_shot_extra_damage(shot)

func fire_charged() -> void :
	executing = true
	character.add_invulnerability("DriftShoryuken")
	weapon_stasis.ExecuteOnce()
	if character.is_on_floor():
		weapon_stasis.play_animation_once("double_cyclone")
	else:
		weapon_stasis.play_animation_once("double_cyclone_air")
	character.animatedSprite.material.set_shader_param("Alpha", 1)
	$sfx_yeti.play()
	frost_tower_2()
	Tools.timer(0.03, "frost_tower_2", self)
	Tools.timer(0.06, "frost_tower_2", self)
	Tools.timer(0.09, "frost_tower_2", self)
	Tools.timer(0.12, "frost_tower_2", self)
	Tools.timer(0.15, "frost_tower_2", self)
	Tools.timer(0.18, "frost_tower_2", self)
	Tools.timer(0.21, "frost_tower_2", self)
	Tools.timer(0.24, "frost_tower_2", self)
	Tools.timer(0.4, "finish", self)

func frost_tower_2() -> void :
	create_double_cyclone(character.global_position, double_cyclone_damage, 600)
	create_double_cyclone(character.global_position, double_cyclone_damage, -600)

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

func create_double_cyclone(ground_position,  damage_value, speed) -> void :
	var instance = double_cyclone_projectile.instance()
	ground_position.y += -4
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.damage = damage_value * 2 * extra_damage
	instance.damage_to_bosses = damage_value * extra_damage
	instance.damage_to_weakness = damage_value * 2 * extra_damage
	instance.set_horizontal_speed(speed)
	if speed > 0:
		instance.scale.x = 1
	else:
		instance.scale.x = -1
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", character.get_facing_direction())
