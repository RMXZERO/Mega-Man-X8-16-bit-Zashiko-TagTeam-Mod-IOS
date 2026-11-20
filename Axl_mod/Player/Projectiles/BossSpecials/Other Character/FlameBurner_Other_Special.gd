extends Node2D

onready var main: = $".."
onready var character: = get_parent().get_parent()
onready var player_damage: = character.get_node("Damage")
onready var player_shot_node: = character.get_node("Shot")
onready var player_altshot_node: = character.get_node("AltFire")

onready var animatedSprite: AnimatedSprite = $animatedSprite
onready var light: Light2D = $light
onready var smoke_particles: = $smoke
onready var sfx: = $sfx
onready var damage_sfx: = $damage

var aura_time: float = 16.0
var flame_frames: Array = [1.0]
var light_color: Color = Color.orange
var damage_factor = 1.5
var shot_damage_values: Dictionary = {}
var alt_damage_values: Dictionary = {}
var aura_show: bool = false

var flame_aura_timer: float = 0.0
var flame_aura_time: float = 0.2
var small_flame_timer: float = 0.0
var small_flame_time: float = 0.2
var small_flame_tower_time: float = 0.2
var small_flame_height: int = 12

var damage_tick_timer: float = 0.0
var damage_tick_time: float = 1.0
var damage_per_tick: float = 1.0

func _ready() -> void :
	Event.listen("axl_special_ability", self, "ability_parts")

func ability_parts(ability_name: String):
	if not CharacterManager.share_axl_buff or not "share_axl_buff" in GameManager.collectibles:
		aura_show = false
		animatedSprite.hide()
		smoke_particles.emitting = false
		smoke_particles.hide()
		smoke_particles.amount = 1
		small_flame_timer = 0
		flame_aura_timer = 0
		set_physics_process(false)
		character.call("equip_cancel_axl_flameburner_parts")
		return
	if ability_name == "flameburner":
		aura_show = true
		animatedSprite.show()
		smoke_particles.emitting = true
		smoke_particles.show()
		smoke_particles.amount = 15
		small_flame_timer = 0
		flame_aura_timer = 0
		set_physics_process(true)
		character.call("equip_axl_flameburner_parts")
	else:
		aura_show = false
		animatedSprite.hide()
		smoke_particles.emitting = false
		smoke_particles.hide()
		smoke_particles.amount = 1
		small_flame_timer = 0
		flame_aura_timer = 0
		set_physics_process(false)
		character.call("equip_cancel_axl_flameburner_parts")

func _physics_process(delta: float) -> void :
	if aura_show:
		light.light(0.3 * rand_range(1.5, 2.0), Vector2(2.5 * rand_range(1.0, 1.5), 2 * rand_range(1.0, 1.5)), light_color)
		small_flame_timer -= delta
		if small_flame_timer <= 0:
			small_flame_timer = small_flame_time
		flame_aura_timer -= delta
		if flame_aura_timer <= 0:
			flame_aura_timer = flame_aura_time
			sfx.play()
		reduce_health(delta)

func reduce_health(delta: float) -> void :
	if not character.is_current_player:
		return
	damage_tick_timer += delta
	if damage_tick_timer >= damage_tick_time:
		damage_tick_timer = 0.0
		if character.current_health > 1:
			player_damage.emit_signal("reduced_health", damage_per_tick)
			character.current_health -= damage_per_tick
			character.flash()
			damage_sfx.play()

func set_aura_buff() -> void :
	for shot in player_shot_node.get_children():
		if shot is WeaponAxl:
			var path = shot.get_path()
			shot_damage_values[path] = {
				"projectile_damage": shot.projectile_damage, 
				"projectile_damage_to_bosses": shot.projectile_damage_to_bosses, 
				"projectile_damage_to_weakness": shot.projectile_damage_to_weakness
			}
			shot.projectile_damage *= damage_factor
			shot.projectile_damage_to_bosses *= damage_factor
			shot.projectile_damage_to_weakness *= damage_factor
	for shot in player_altshot_node.get_children():
		if shot is WeaponAxl:
			var path = shot.get_path()
			alt_damage_values[path] = {
				"projectile_damage": shot.projectile_damage, 
				"projectile_damage_to_bosses": shot.projectile_damage_to_bosses, 
				"projectile_damage_to_weakness": shot.projectile_damage_to_weakness
			}
			shot.projectile_damage *= damage_factor
			shot.projectile_damage_to_bosses *= damage_factor
			shot.projectile_damage_to_weakness *= damage_factor

func unset_aura_buff() -> void :
	for shot in player_shot_node.get_children():
		if shot is WeaponAxl:
			var path = shot.get_path()
			if shot_damage_values.has(path):
				var original = shot_damage_values[path]
				shot.projectile_damage = original.projectile_damage
				shot.projectile_damage_to_bosses = original.projectile_damage_to_bosses
				shot.projectile_damage_to_weakness = original.projectile_damage_to_weakness
	for shot in player_altshot_node.get_children():
		if shot is WeaponAxl:
			var path = shot.get_path()
			if alt_damage_values.has(path):
				var original = alt_damage_values[path]
				shot.projectile_damage = original.projectile_damage
				shot.projectile_damage_to_bosses = original.projectile_damage_to_bosses
				shot.projectile_damage_to_weakness = original.projectile_damage_to_weakness
	shot_damage_values.clear()
	alt_damage_values.clear()
