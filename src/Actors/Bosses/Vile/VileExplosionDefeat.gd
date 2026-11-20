extends TeamBossDeath

func _Setup() -> void:
	._Setup()
	if character.name == "Vile Awaken":
		Event.emit_signal("vileex_defeated")
		Event.emit_signal("call_fade_out_battle")
	else:
		Event.emit_signal("vile_defeated")

func _Interrupt() -> void:
	if not not_self_end and not already_end and defeated_flag != "none" and defeated_flag != "vile_palace_defeated":
		GameManager.end_boss_death_cutscene()
	if defeated_flag == "none" or defeated_flag == "vile_palace_defeated":
		GameManager.end_cutscene()
		Event.emit_signal("play_stage_song")
		Event.emit_signal("boss_health_hide")
	Event.emit_signal("enemy_kill", "sigma_palace_vile")
	emit_signal("screen_flash")
	elapsed_explosion_time = 0.0
	elapsed_alpha_time = 0.0
	elapsed_color_time = 0.0
	tempo = 0
	darken = 1
	sprite_alpha = 1
	freeze_over = false
	explosion_over = false
	collectible()
	achievement_check()
	add_weapon_to_savedata()
	if defeated_flag != "none":
		#GlobalVariables.set(defeated_flag,"defeated")
		GlobalVariables.add(defeated_flag, "defeated")
	Event.emit_signal("boss_2_death", null)
	get_parent().queue_free()

func emit_flash_signals():
	if not emitted_flash:
		emitted_flash = true
		#Event.emit_signal("boss_death_screen_flash")
		emit_signal("screen_flash")

func achievement_check() -> void :
	if defeated_flag == "vile_ex_defeated":
		Achievements.unlock("AWAKENVILEDEFEATED")
		if "X" in CharacterManager.team:
			if CharacterManager.infinite_x_activated:
				return
		if "Zero" in CharacterManager.team:
			if CharacterManager.awakened_zero_armor and CharacterManager.awakened_zero_full_power_max:
				return
		if "Axl" in CharacterManager.team:
			if CharacterManager.cheat_axl_activated:
				return
		if Configurations.get("ShowDebug"):
			return
		if GameManager.used_cheats:
			return
		Achievements.unlock("AWAKENVILECHEATDEFEATED")
	
