extends Node
class_name BossWeapon

export  var active: = false
export  var debug_logs: = false
export  var can_buffer: = true
export  var weapon: Resource
export  var current_ammo: = 28.0
export  var shoot_delay: float = 1
const max_ammo: = 28.0
const chargeable_without_ammo: = false
var timer: = 0.0
var cooldown: SceneTreeTween
onready var character: Character = get_parent().get_parent()
onready var buster: = get_parent()
onready var shot_position: Node2D = $"../../Shot Position"
var last_fired_shot_was_charged: = false
onready var arm_cannon = character.get_node("Shot")
onready var charge_max = character.get_node_or_null("Charge")
var extra_damage: float = 1

func fire(charge_level) -> void :
	if CharacterManager.ultimate_buster and not CharacterManager.weaponget:
		if arm_cannon.upgraded:
			if has_ammo() and not buster.has_infinite_charged_ammo():#Hermes
				Log("Firing Charged Shot")
				reduce_charged_ammo()
				fire_charged()
				start_charge_cooldown()
				last_fired_shot_was_charged = true
			elif buster.has_infinite_charged_ammo():#Icarus
				Log("Firing Charged Shot")
				reduce_charged_ammo()
				fire_charged()
				start_charge_cooldown()
				last_fired_shot_was_charged = true
			else:#Hermes no ammo
				Log("Firing Regular Shot")
				reduce_regular_ammo()
				fire_regular()
				start_cooldown()
				last_fired_shot_was_charged = false
				arm_cannon.actions[0] = "fire"
		else:#Normal
			Log("Firing Regular Shot")
			reduce_regular_ammo()
			fire_regular()
			start_cooldown()
			last_fired_shot_was_charged = false
			arm_cannon.actions[0] = "fire"
	else:
		if charge_level >= 3:
			if charge_max != null:
				if charge_max.max_charge:
					Log("Firing Charged Shot")
					reduce_charged_ammo()
					fire_charged()
					start_charge_cooldown()
					last_fired_shot_was_charged = true
		else:
			if charge_max != null:
				if not charge_max.max_charge:
					Log("Firing Regular Shot")
					reduce_regular_ammo()
					fire_regular()
					start_cooldown()
					last_fired_shot_was_charged = false

func start_cooldown() -> void :
	if cooldown:
		cooldown.kill()
	timer = weapon.cooldown
	Log("Setting cooldown to " + str(weapon.cooldown))
	cooldown = create_tween()
	cooldown.tween_property(self, "timer", 0, weapon.cooldown)
	cooldown.tween_callback(self, "buster_notify_cooldown_end")

func start_charge_cooldown() -> void :
	if CharacterManager.ultimate_buster:
		start_ultimate_buster_cooldown()
		return
	if cooldown:
		cooldown.kill()
	timer = weapon.cooldown
	Log("Setting cooldown to " + str(weapon.cooldown))
	cooldown = create_tween()
	if weapon.collectible == "mantis_weapon" or weapon.collectible == "sunflower_weapon":
		cooldown.tween_property(self, "timer", 0, weapon.cooldown * 6)
	else:
		cooldown.tween_property(self, "timer", 0, weapon.cooldown)
	cooldown.tween_callback(self, "buster_notify_cooldown_end")

func start_ultimate_buster_cooldown() -> void :
	if cooldown:
		cooldown.kill()
	timer = weapon.cooldown
	Log("Setting cooldown to " + str(weapon.cooldown))
	cooldown = create_tween()
	if CharacterManager.xdrive:
		cooldown.tween_property(self, "timer", 0, charge_max.level_4_charge * (1 - charge_max.charge_time_reduction) * 0.5)
	else:
		cooldown.tween_property(self, "timer", 0, charge_max.level_4_charge * (1 - charge_max.charge_time_reduction))
	cooldown.tween_callback(self, "buster_notify_cooldown_end")

func buster_notify_cooldown_end() -> void :
	buster.weapon_cooldown_ended(self)

func is_cooling_down() -> bool:
	return timer > 0

func has_ammo() -> bool:
	return current_ammo > 0

func fire_regular() -> void :
	play(weapon.sound)
	var shot = instantiate_projectile(weapon.regular_shot)
	set_position_as_shot_position(shot)
	set_shot_extra_damage(shot)

func fire_charged() -> void :
	play(weapon.charged_sound)
	var shot = instantiate_projectile(weapon.charged_shot)
	set_position_as_shot_position(shot, - 24.0)
	set_shot_extra_damage(shot)

func set_position_as_shot_position(shot, offset: = 0.0) -> void :
	var dir = character.get_facing_direction()
	var pos = Vector2(character.global_position.x + shot_position.position.x * dir, shot_position.global_position.y)
	pos.x += offset * dir
	shot.global_position = pos

func set_position_as_character_position(shot) -> void :
	var pos = Vector2(character.global_position.x, character.global_position.y)
	shot.global_position = pos
	
func set_shot_extra_damage(shot) -> void :
	shot.damage *= extra_damage
	shot.damage_to_bosses *= extra_damage
	shot.damage_to_weakness *= extra_damage

func reduce_regular_ammo() -> void :
	if not buster.has_infinite_regular_ammo():
		reduce_ammo(weapon.regular_ammo_cost)

func reduce_charged_ammo() -> void :
	if not buster.has_infinite_charged_ammo():
		reduce_ammo(weapon.charged_ammo_cost)

func has_max_ammo() -> bool:
	return current_ammo >= max_ammo

func reduce_all_ammo() -> void :
	reduce_ammo(max_ammo)

func reduce_ammo(value) -> void :
	Log("Reducing ammo by " + str(value))
	current_ammo -= value
	current_ammo = clamp(current_ammo, 0.0, max_ammo)

func increase_ammo(value) -> float:
	Log("Recharging ammo by " + str(value))
	var excess_value: = 0.0
	current_ammo += value
	if current_ammo > max_ammo:
		excess_value = max_ammo - current_ammo
		Log("Excess value: " + str(value))
	current_ammo = clamp(current_ammo, 0.0, max_ammo)
	return excess_value

func instantiate(scene: PackedScene) -> Node2D:
	var instance = scene.instance()
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(GameManager.get_player_position())
	return instance
	
func instantiate_projectile(scene: PackedScene) -> Node2D:
	if not scene:
		push_error("No projectile set.")
		return null
	var projectile = instantiate(scene)
	projectile.set_creator(character)
	projectile.call_deferred("initialize", character.get_facing_direction())
	
	return projectile

func get_palette():
	return weapon.get_palette()

func get_ammo() -> float:
	return current_ammo

func get_charge_color():
	return weapon.get_charge_color()

func should_unlock(collectible: String) -> bool:
	return collectible == weapon.collectible

func Log(message) -> void :
	if debug_logs:
		print(character.name + ". " + name + ": " + message)

func play(sound) -> void :
	buster.play_sound(sound, true)

func make_character_visible() -> void :
	character.animatedSprite.modulate = Color(1, 1, 1, 1)
	
func make_character_invisible() -> void :
	character.animatedSprite.modulate = Color(1, 1, 1, 0.01)
