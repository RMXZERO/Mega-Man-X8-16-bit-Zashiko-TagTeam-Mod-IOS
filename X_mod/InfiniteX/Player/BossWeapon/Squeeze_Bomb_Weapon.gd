extends BossWeapon

onready var squeeze_bomb_projectile: PackedScene = preload("res://X_mod/InfiniteX/Player/Projectiles/UX_SqueezeBombCharged.tscn")
var creator: Node2D
var squeeze_bomb_damage = 3

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
	weapon_stasis.play_animation_once("falcongiga")
	character.animatedSprite.material.set_shader_param("Alpha", 1)
	$"../../animatedSprite".frame = 8
	Tools.timer(0.1, "squeeze_bomb", self)
	Tools.timer(0.8, "finish", self)

func squeeze_bomb() -> void :
	create_squeeze_bomb(character.global_position + Vector2(-20, 0), squeeze_bomb_damage)

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
		weapon_stasis.EndAbility()
		character.set_horizontal_speed(0)
		character.set_vertical_speed(0)
		tween.reset()
		Tools.timer_p(0.25, "remove_invulnerability", character, "DriftShoryuken")

func _on_Forced_ability_start(_ability) -> void :
	if executing:
		finish()

func create_squeeze_bomb(ground_position,  damage_value) -> void :
	var instance = squeeze_bomb_projectile.instance()
	ground_position.y += 0
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.damage = damage_value * 2 * extra_damage
	instance.damage_to_bosses = damage_value * extra_damage
	instance.damage_to_weakness = damage_value * extra_damage * 3
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", character.get_facing_direction())
