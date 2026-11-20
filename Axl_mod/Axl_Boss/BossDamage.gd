extends BossDamage

const exceptions = ["RideArmor", "Optic", "Fire", "Flame", "Enkoujin", "Juuhazan", "Enkoujin_Charged", "Enkoujin_Charged_B", "GigaCrashCharged", "Genmuzerowave", "GenmuzeroCharged", "Rekohouha", "Shingetsurin", "NovaStrikeCharged", "ShoryuukenCharged", "Player_Desperation"]
onready var panda: Node2D = $"../Panda"
onready var main = get_parent()
var player_material_falsh_on: bool = true

func reduce_health(_damage, inflicter) -> void :
	debug_last_hit = OS.get_ticks_msec()
	Event.emit_signal("hit_enemy")
	player_material_falsh_on = true
	var dmg_value: float = 1
	if "damage_to_bosses" in inflicter:
		dmg_value = (inflicter.damage_to_bosses * damage_reduction) * CharacterManager.damage_deal_multiplier
		
	if "Saber" in inflicter.name or "Rekkyoudan" in inflicter.name:
		if main.only_zero:
			$damage.play()
			if dmg_value >= 16:
				invulnerability_time = weakness_invulnerability_time
				dmg_value = handle_weakness(inflicter)
				emit_signal("charged_weakness_hit", get_inflicter_direction(inflicter))
			else:
				if inflicter.break_guards:
					invulnerability_time = weakness_invulnerability_time
					dmg_value = handle_weakness(inflicter)
					emit_signal("charged_weakness_hit", get_inflicter_direction(inflicter))
				else:
					invulnerability_time = normal_invulnerability_time
			max_flash_time = invulnerability_time
			character.reduce_health(dmg_value)
			emit_signal("took_damage")
			emit_signal("got_hit", inflicter)
			increment_pds(dmg_value)
			return

	if is_weakness(inflicter):
		dmg_value = handle_weakness(inflicter)
		$damage.play()
	else:
		if dmg_value >= 24:
			$damage.play()
			invulnerability_time = charged_weakness_invul_time
			emit_signal("charged_weakness_hit", get_inflicter_direction(inflicter))
		else:
			invulnerability_time = normal_invulnerability_time
		character.reduce_health(dmg_value)
		max_flash_time = normal_flash_time
	emit_signal("took_damage")
	emit_signal("got_hit", inflicter)
	increment_pds(dmg_value)

func should_ignore_damage (inflicter) -> bool:
	if panda.executing and panda.attack_stage >= 3:
		if character.is_invulnerable() or not character.has_health():
			return true
			
		if only_on_screen and not GameManager.is_on_screen(character.global_position):
			return true
			
		if inflicter.global_position.y > global_position.y + 17:
			for word in exceptions:
				if word in inflicter.name:
					return false
			return true

		if ignore_nearby_hits and character.has_shield():
			if "bypass_shield" in inflicter:
				return false
			if character.get_direction() > 0 and inflicter.get_facing_direction() < 0:
				return true
			elif character.get_direction() < 0 and inflicter.get_facing_direction() > 0:
				return true
		return false
	else:
		return .should_ignore_damage(inflicter)

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
