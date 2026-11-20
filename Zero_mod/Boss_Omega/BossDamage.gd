extends BossDamage

onready var main = get_parent()
onready var weakness: AudioStreamPlayer = get_parent().get_node("weakness")
onready var oz_weakness: AudioStreamPlayer = get_parent().get_node("oz_weakness")
var player_material_falsh_on: bool = true

func _ready() -> void:
	._ready()
	remove_weaknesses()

func reduce_health(_damage, inflicter) -> void :
	debug_last_hit = OS.get_ticks_msec()
	Event.emit_signal("hit_enemy")
	player_material_falsh_on = true
	var dmg_value: float = 1
	if "damage_to_bosses" in inflicter:
		dmg_value = (inflicter.damage_to_bosses * damage_reduction) * CharacterManager.damage_deal_multiplier
		
	if is_weakness(inflicter):
		dmg_value = handle_weakness(inflicter)
	else:
		character.reduce_health(dmg_value)
		max_flash_time = normal_flash_time
		invulnerability_time = normal_invulnerability_time
		
	if animatedSprite.animation == "jump" and main.is_executing("7SlashCombo") or animatedSprite.animation == "fall":
		if dmg_value > 1:
			emit_signal("charged_weakness_hit", get_inflicter_direction(inflicter))
			if main.only_x:
				weakness.play()
			else:
				oz_weakness.play()
		
	emit_signal("took_damage")
	emit_signal("got_hit", inflicter)
	increment_pds(dmg_value)

func handle_weakness(inflicter) -> float:
	var dmg_value = 0.0
	if CharacterManager.game_mode <= 0:
		dmg_value = (inflicter.damage_to_weakness * weakness_multiplier * damage_reduction)
	else:
		dmg_value = (inflicter.damage_to_weakness * weakness_multiplier * damage_reduction) * CharacterManager.damage_deal_multiplier
	character.reduce_health(dmg_value)
	if "Charged" in inflicter.name or "Punch" in inflicter.name:
		invulnerability_time = charged_weakness_invul_time
		emit_signal("charged_weakness_hit", get_inflicter_direction(inflicter))
		if main.only_x:
			weakness.play()
		else:
			oz_weakness.play()
	else:
		invulnerability_time = weakness_invulnerability_time
	max_flash_time = invulnerability_time
	return dmg_value

func _physics_process(delta: float) -> void :
	._physics_process(delta)
	if not character.has_health():
		player_flash()
		return
	if not character.is_invulnerable():
		animatedSprite.material.set_shader_param("Flash", 0)
	
	if player_material_falsh_on:
		if character.is_invulnerable():
			animatedSprite.material.set_shader_param("Flash", 1)
			Tools.timer(0.05, "player_flash", self)
			player_material_falsh_on = false
		else:
			animatedSprite.material.set_shader_param("Flash", 0)

func player_flash() -> void :
	animatedSprite.material.set_shader_param("Flash", 0)
	Tools.timer(0.05, "can_flash_again", self)

func can_flash_again() -> void :
	player_material_falsh_on = true

func play_shader() -> void :
	pass

func stop_shader() -> void :
	pass
