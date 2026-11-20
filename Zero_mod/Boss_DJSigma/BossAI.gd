extends BossAI

var next_attack_time = 0.1

func set_game_mode():
	desperation_multi = 10
	if CharacterManager.game_mode <= -1:
		next_attack_time = 0.15
	elif CharacterManager.game_mode == 0:
		next_attack_time = 0.1
	elif CharacterManager.game_mode == 1:
		next_attack_time = 0.075
	elif CharacterManager.game_mode == 2:
		next_attack_time = 0.05
	elif CharacterManager.game_mode >= 3:
		next_attack_time = 0.25

func decide_time_for_next_attack():
	set_game_mode()
	timer_for_next_attack = next_attack_time
