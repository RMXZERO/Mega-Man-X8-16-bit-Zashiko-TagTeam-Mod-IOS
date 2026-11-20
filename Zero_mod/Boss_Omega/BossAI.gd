extends BossAI

var next_attack_time = 0.1

func set_game_mode():
	if CharacterManager.game_mode <= -1:
		next_attack_time = 0.025
	elif CharacterManager.game_mode == 0:
		next_attack_time = 0
	elif CharacterManager.game_mode == 1:
		next_attack_time = 0
	elif CharacterManager.game_mode == 2:
		next_attack_time = 0
	elif CharacterManager.game_mode >= 3:
		next_attack_time = 0

func decide_time_for_next_attack():
	set_game_mode()
	timer_for_next_attack = next_attack_time
