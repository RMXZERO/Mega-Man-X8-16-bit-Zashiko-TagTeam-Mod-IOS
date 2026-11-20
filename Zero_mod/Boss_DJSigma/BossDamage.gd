extends BossDamage

onready var main = get_parent()

func _ready() -> void:
	._ready()

func reduce_health(_damage, inflicter) -> void :
	debug_last_hit = OS.get_ticks_msec()
	Event.emit_signal("hit_enemy")
	var dmg_value: float = 1
	if "damage_to_bosses" in inflicter:
		dmg_value = (inflicter.damage_to_bosses * damage_reduction) * CharacterManager.damage_deal_multiplier
		
	if is_weakness(inflicter):
		dmg_value = handle_weakness(inflicter)
	else:
		if main.virus_start:
			character.reduce_health(dmg_value/2)
		else:
			character.reduce_health(dmg_value)
		invulnerability_time = normal_invulnerability_time * 3
		max_flash_time = invulnerability_time
		
	emit_signal("took_damage")
	emit_signal("got_hit", inflicter)
	increment_pds(dmg_value)

func handle_weakness(inflicter) -> float:
	var dmg_value = 0.0
	if CharacterManager.game_mode <= 0:
		dmg_value = (inflicter.damage_to_weakness * weakness_multiplier * damage_reduction)
	else:
		dmg_value = (inflicter.damage_to_weakness * weakness_multiplier * damage_reduction) * CharacterManager.damage_deal_multiplier
	if main.virus_start:
		character.reduce_health(dmg_value/2)
	else:
		character.reduce_health(dmg_value)
	if "Charged" in inflicter.name or "Punch" in inflicter.name:
		invulnerability_time = charged_weakness_invul_time * 2
		emit_signal("charged_weakness_hit", get_inflicter_direction(inflicter))
	else:
		invulnerability_time = weakness_invulnerability_time * 2
	max_flash_time = invulnerability_time
	return dmg_value

func _physics_process(delta: float) -> void :
	._physics_process(delta)

