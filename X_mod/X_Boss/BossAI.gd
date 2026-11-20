extends BossAI

var next_attack_time = 0.1

func set_game_mode():
	if CharacterManager.game_mode == -1:
		next_attack_time = 0.3
		desperation_threshold = 0.25
		desperation_multi = 0
		if used_desperation:
			next_attack_time = 0.25
		if CharacterManager.nightshade_zero_armor:
			next_attack_time = 0.02
	elif CharacterManager.game_mode == 0:
		next_attack_time = 0.25
		desperation_threshold = 0.5
		desperation_multi = 2
		if used_desperation:
			next_attack_time = 0.2
		if CharacterManager.nightshade_zero_armor:
			next_attack_time = 0.02
	elif CharacterManager.game_mode == 1:
		next_attack_time = 0.2
		desperation_threshold = 0.75
		desperation_multi = 5
		if used_desperation:
			next_attack_time = 0.15
		if CharacterManager.nightshade_zero_armor:
			next_attack_time = 0.02
	elif CharacterManager.game_mode == 2:
		next_attack_time = 0.15
		desperation_threshold = 1.1
		desperation_multi = 10
		if used_desperation:
			next_attack_time = 0.1
		if CharacterManager.nightshade_zero_armor:
			next_attack_time = 0.025
	elif CharacterManager.game_mode >= 3:
		next_attack_time = 0.1
		desperation_threshold = 1.1
		desperation_multi = 10
		if used_desperation:
			next_attack_time = 0.05
		if CharacterManager.nightshade_zero_armor:
			next_attack_time = 0.02

func decide_time_for_next_attack():
	set_game_mode()
	timer_for_next_attack = next_attack_time
